//
//  ViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 04/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {
                            
    //MARK: Image change
    @IBOutlet weak var photoView: UIImageView!
    
    private func setNewImageInView() {
        
        if let _photo = photo {
            if let _photoView = photoView {     // outlet già settato?
                _photoView.image = _photo.image
            }
        }
    }
    var photo : Photo? = nil {
        
        didSet {
            
            setNewImageInView()
        }
    }
    var imageInfo : String = ""
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // temp
        //image = UIImage(named: "rovi")
        //title = "Photo"
        
        // Questo è necessario perchè il didSet potrebbe essere chiamato prima del load della view (es. prepareForSegue), quando gli outlet (e quindi photoView sono ancora nil)
        setNewImageInView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        //println("viewDidLayoutSubviews");
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
        //println("updateViewConstraints");
    }

    override func supportedInterfaceOrientations() -> Int {
        
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    //MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showInfo" {

                if segue.destinationViewController is PhotoInfoViewController {
                
                let destVC = segue.destinationViewController as PhotoInfoViewController
                
                // prove di modale
                //destVC.modalPresentationStyle = .FormSheet
                //FormSheet
                //PageSheet

                destVC.modalTransitionStyle = .PartialCurl
                //CoverVertical
                //PartialCurl (solo con i full screen)
                
                
                destVC.info = imageInfo
            }
        } else if segue.identifier == "showMap" {
            
            if segue.destinationViewController is PhotoMapViewController {
                
                let destVC = segue.destinationViewController as PhotoMapViewController
                destVC.photo = photo
                
            }
        }
    }
    // unwind
    @IBAction func unwindToPhoto(segue : UIStoryboardSegue) {
        
    }
}

