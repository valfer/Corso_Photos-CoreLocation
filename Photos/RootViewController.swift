//
//  RootViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 05/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit

class RootViewController : UIViewController, ParserProtocol {
    
    var photos : [Photo]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let parser : Parser = Parser()
        parser.delegate = self
        
        // go
        parser.parseStart()
    }
    
    //MARK: Segue
    @IBAction func launchSegue(sender: UIButton) {
        
        self.performSegueWithIdentifier("show", sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var index : Int!
        switch segue.identifier {
            
            case "show":
                index = (sender as UIButton).tag
            case "show1":
                index = 0
            case "show2":
                index = 1
            default:
                index = 2
        }
        
        let photoTitle = photos?[index].titolo
        let photoImage = UIImage(named: photoTitle ?? "rovi")   // es. di cohalesce operator
        let photoInfo = photos?[index].descr
        
        // il VC destinazione
        //println(reflect(segue.destinationViewController).summary)
        if segue.destinationViewController is PhotoViewController {
            
            let photoVC = segue.destinationViewController as PhotoViewController
            photoVC.photo = photos?[index]
            
            /*photoVC.title = photoTitle
            photoVC.image = photoImage
            photoVC.imageInfo = photoInfo ?? ""*/
        }
        
    }
    
    //MARK: ParserProtocol
    func parseEnd(photoArray:[Photo]) {

        photos = photoArray
    }
    
    func parseError(error:NSError) {

        let alert:UIAlertController = UIAlertController(title: "Errore", message: error.localizedDescription, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            
        }))
        self.presentViewController(alert, animated:true, completion:nil);
    }
    
}