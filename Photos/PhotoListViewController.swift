//
//  PhotoListViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 05/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIkit
import MobileCoreServices
import MapKit
import CoreLocation

class PhotoListViewController : UITableViewController, ParserDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var photos : [Photo]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        

        // Uncomment the following line to preserve selection between presentations.
        clearsSelectionOnViewWillAppear = false

        // editing
        //navigationItem.rightBarButtonItem = editButtonItem()
        //editButtonItem().title = "Modifica"

        let parser : Parser = Parser()
        parser.delegate = self
        
        // refresh control
        refreshControl = UIRefreshControl()
        let hOff = -refreshControl!.bounds.size.height
        tableView.setContentOffset(CGPointMake(0, hOff), animated: true)
        refreshControl?.beginRefreshing()
        
        refreshControl?.addTarget(self, action: "refreshData", forControlEvents: .ValueChanged)
        
        // go
        parser.start()
    }
    
    //MARK: Refresh Control Callback
    func refreshData() {
        
        // do nothing (solo un esempio)
        refreshControl?.endRefreshing()
    }

    //MARK: ParserProtocol
    func parserOK(photoArray:[Photo]) {
        
        photos = photoArray
        tableView.reloadData()
        refreshControl?.endRefreshing()
        
        // faccio vedere la prima nella detail dello split
        let photo = photoArray[0]
        //let detailVC = self.splitViewController?.viewControllers.last as UINavigationController
        //let photoVC = detailVC.topViewController as PhotoViewController
        
        if self.splitViewController?.collapsed == false {

            let photoVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("photovc") as PhotoViewController
            photoVC.title = photo.titolo
            photoVC.photo = photo
            //photoVC.image = UIImage(named: photo.titolo)
            //photoVC.imageInfo = photo.descr
            let navigationVC = UINavigationController(rootViewController: photoVC)
            self.showDetailViewController(navigationVC, sender: self)
        }
    }
    
    func parserKO(error:NSError) {
        
        let alert:UIAlertController = UIAlertController(title: "Errore", message: error.localizedDescription, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
        }))
        self.presentViewController(alert, animated:true, completion:nil);
    }
    
    // cambio scritta del tasto edit
    override func setEditing(editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        if editing {
            editButtonItem().title = "Salva"
        } else {
            editButtonItem().title = "Modifica"
        }
    }
    
    //MARK: UITableViewDelegate
    
    /*override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let photoVC = UIStoryboard(name:"Main", bundle:nil).instantiateViewControllerWithIdentifier("photovc") as PhotoViewController
        let photo : Photo! = photos?[indexPath.row]
        photoVC.title = photo.titolo
        photoVC.image = UIImage(named: photo.titolo)
        photoVC.imageInfo = photo.descr
        self.showDetailViewController(photoVC, sender: self)
        
    }*/

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return indexPath.row == 0 ? false : true
    }
    
    // editing
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return photos?.count ?? 0
    }

    // move
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }

    // la swap vuole inout e inout Photo non è subscriptable
    func exchange<T>(data:[T], i:Int, j:Int) -> [T] {
        
        var newData = data
        newData[i] = data[j]
        newData[j] = data[i]
        
        return newData
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        if let _photos = photos {
            
            photos = exchange(_photos, i: sourceIndexPath.row, j: destinationIndexPath.row)
            //println(photos)
        }
    }
    
    // delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            // cancelliamo la row dal data source
            photos?.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    
    //MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:indexPath) as UITableViewCell
        
        let photo = photos?[indexPath.row]
        
        if let _photo = photo {
            
            cell.textLabel!.text = _photo.titolo
            cell.detailTextLabel?.text = _photo.autore
            //let image = UIImage(named: _photo.titolo)
            cell.imageView?.image = _photo.thumb
            cell.accessoryType = .DisclosureIndicator

        }
        
        return cell
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            
        if segue.destinationViewController is UINavigationController {

            let destinationVC = (segue.destinationViewController as UINavigationController).topViewController
            //let destinationVC: AnyObject = segue.destinationViewController

                if destinationVC is PhotoViewController {

                    let photoVC = destinationVC as PhotoViewController
                    let indexPath : NSIndexPath! = self.tableView.indexPathForCell(sender as UITableViewCell)
                    let photo : Photo! = photos?[indexPath.row]
                    photoVC.title = photo.titolo
                    photoVC.photo = photo
                    let splitDelegate = self.splitViewController as PhotoSplitViewController
                    splitDelegate.selectedPhoto = indexPath.row
                    //photoVC.imageInfo = photo.descr
                }
            }
        }
    }

    //MARK: Camera take shot
    
    var picker : UIImagePickerController!
    
    @IBAction func takeNewPhoto(sender: AnyObject) {
        
        startFindMyPosition()
    }
    
    func showPhotoPicker() {
        
        // definiamo il tipo di source che vogliamo
        let sourceType : UIImagePickerControllerSourceType = .Camera
        
        // abbiamo una fotocamera su questa device?
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            
            // quali media types fornisce questa telecamera?
            let availMediaTypes = UIImagePickerController.availableMediaTypesForSourceType(sourceType) as [String]
            println(availMediaTypes)
            
            // kUTTypeImage N.B. è uno CFStringRef definito in MobileCoreServices (quindi lo dobbiamo importare)
            if contains(availMediaTypes, String(kUTTypeImage)) {
                
                picker = UIImagePickerController()
                picker.sourceType = sourceType
                // vogliamo image generiche (altrimenti png jpeg etc se cerco in photo library)
                picker.mediaTypes = [String(kUTTypeImage)]
                picker.allowsEditing = true
                // questa deve rispondere a due protocolli (anche navigator)
                picker.delegate = self;
                
                presentViewController(picker, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        var image = info[UIImagePickerControllerOriginalImage] as UIImage?
        let edited = info[UIImagePickerControllerEditedImage] as UIImage?
        if edited != nil {
            image = edited
        }
        if let _image = image {
        
            let newPhoto = Photo(date : NSDate())
            newPhoto.titolo = "Nuova foto"
            newPhoto.autore = "io"
            newPhoto.descr = "n.d."
            newPhoto.image = _image
            if userCoordinate != nil {
                newPhoto.latitudine = userCoordinate!.latitude
                newPhoto.longitudine = userCoordinate!.longitude
            } else {
                newPhoto.latitudine = 0
                newPhoto.longitudine = 0
            }
            photos?.insert(newPhoto, atIndex: 0)
            tableView.reloadData()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: core location
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
            showPhotoPicker()
            stopFindMyPosition()
        }
    }
    
}



