//
//  RootViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 05/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit
import CoreLocation
import MobileCoreServices

class RootViewController : UIViewController, ParserDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate {
    
    var photos : [Photo] = [Photo]()
    let parser = Parser()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        positionLabel.text = ""

        parser.delegate = self
        parser.start()
    }
    
    //MARK: Segue
    @IBAction func launchSegue(sender: UIButton) {
        
        self.performSegueWithIdentifier("show", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier != nil {
        
            var index : Int!
            index = (sender as UIButton).tag
            
            let photoTitle = photos[index].titolo
            let photoImage = UIImage(named: photoTitle ?? "rovi")   // es. di cohalesce operator
            let photoInfo = photos[index].descr
            
            // il VC destinazione
            //println(reflect(segue.destinationViewController).summary)
            if segue.destinationViewController is PhotoViewController {
                
                let photoVC = segue.destinationViewController as PhotoViewController
                photoVC.title = photoTitle
                photoVC.photo = photos[index]
                photoVC.imageInfo = photoInfo ?? ""
            }
        }
    }
    
    //MARK: ParserProtocol
    func parserOK(photoArray:[Photo]) {

        photos = photoArray
    }
    
    func parserKO(error:NSError) {

        let alert:UIAlertController = UIAlertController(title: "Errore", message: error.localizedDescription, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
        }))
        self.presentViewController(alert, animated:true, completion:nil);
    }
    
    //MARK: core location

    @IBOutlet weak var positionLabel: UILabel!
    
    @IBAction func findMyPosition(sender: AnyObject) {
        
        startFindMyPosition()
    }
    var locManager : CLLocationManager?
    var userCoordinate : CLLocationCoordinate2D?
    var locationStartTime : NSDate?
    var locTrying = false
    
    func startFindMyPosition() {
        
        if locTrying {
            return
        }
        
        // richiedo autorizzazione per usare posizione dell'utente. Aggoingi anche stringa in info.plit con frase "La tua posizione sarà usata per la geolocalizzazione della foto da te scattata"
        if CLLocationManager.locationServicesEnabled() {
            
            let status = CLLocationManager.authorizationStatus()
            /*
            case NotDetermined
            case Restricted
            case Denied
            case Authorized
            case AuthorizedWhenInUse
            */
            // se p.e. lo stato è denied, prima di proseguire dovrei richiedere all'utente di cambiare le opzioni e concedere il permesso, (da iOS8 è possibile anche aprire direttamente la app settings sulla privacy della mia app)
            println(status.rawValue)
            
            locManager = CLLocationManager()
            if let _locManager = locManager {
                
                _locManager.requestWhenInUseAuthorization()
                _locManager.delegate = self
                _locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                _locManager.activityType = .Other
                
                _locManager.startUpdatingLocation()
                
                locTrying = true
                
                // se non ottengo la posizione desiderata devo comunque fermarmi ad un certo punto, infatti il manager non mi chiama più e non ho modo di mostrare il picker
                let delay = 6.0 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    println("Timeout")
                    self.stopFindMyPosition()
                })
                
            }
        }
    }
    
    func stopFindMyPosition() {
        
        if let _locManager = locManager {
            
            _locManager.stopUpdatingLocation()
            locManager = nil
            locTrying = false
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
        println(error)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = locations.last as CLLocation
        
        // accuratezza
        let accuracy = location.horizontalAccuracy
        
        // tempo
        let time = location.timestamp
        if locationStartTime == nil {
            locationStartTime = NSDate()
        }
        var secs = time.timeIntervalSinceDate(locationStartTime!)
        if secs < 0 {
            secs = 0
        }
        
        println("Trying since \(secs) secs: \(location.coordinate.latitude) \(location.coordinate.longitude) (\(accuracy))")
        
        // salviamo la posizione
        let requiredAccuracy = 100.0  // metri
        let maxWait = 10.0            // secs
        userCoordinate = location.coordinate
        if (accuracy >= 0 && accuracy <= requiredAccuracy) || Double(secs) > maxWait {
            
            println("Got it!")
            let position = NSString(format: "lat. %3.2f, long. %3.2f", location.coordinate.latitude, location.coordinate.longitude)
            positionLabel.text = position
            stopFindMyPosition()
        }
    }

}