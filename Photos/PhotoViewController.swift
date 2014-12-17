//
//  ViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 04/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
        
    //MARK: Image change
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private func setNewImageInView() {
        
        if let _photo = photo {
            if let _photoView = photoView {     // outlet già settato?
                _photoView.image = _photo.image
                let photoSplit = self.splitViewController as PhotoSplitViewController
                //photoSplit.preferredDisplayMode = .PrimaryHidden
                /*if let _masterPopover = photoSplit.masterPopover {
                    _masterPopover.dismissPopoverAnimated(true)
                }*/
                
                self.scrollView.contentOffset = CGPointMake(0, 0)
                self.scrollView.zoomScale = 1
            }
        }
    }
    var photo : Photo? = nil {
        
        didSet {
            
            setNewImageInView()
        }
    }
    //var imageInfo : String = ""
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // temp
        //image = UIImage(named: "rovi")
        //title = "Photo"
        
        // Questo è necessario perchè il didSet potrebbe essere chiamato prima del load della view (es. prepareForSegue), quando gli outlet (e quindi photoView sono ancora nil)
        setNewImageInView()
        //self.splitViewController?.delegate = self
        
        let splitDelegate = self.splitViewController as PhotoSplitViewController
        let button = splitDelegate.displayModeButtonItem()
        self.navigationItem.setLeftBarButtonItem(splitDelegate.displayModeButtonItem(), animated: true)
        
    }

    private func setDelegate(delegate : UIViewController?) {
        
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

                //destVC.modalTransitionStyle = .PartialCurl
                //CoverVertical
                //PartialCurl (solo con i full screen)
                
                
                destVC.info = photo?.descr
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

    //MARK: Scroll delegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        
        return photoView
    }

    // nota che la detail viene deallocata quando cambio photo (nuovo in iOS8), quindi non può essere lei la delegate (come in passato)
    deinit {
        //println("PhotoViewController deinit")
        //self.splitViewController?.delegate = nil
    }
    
    //MARK: Popover
    
    @IBAction func showPopover(sender: UIButton) {

        var popoverContent = self.storyboard?.instantiateViewControllerWithIdentifier("photoInfo") as PhotoInfoViewController
        popoverContent.modalPresentationStyle = .Popover
        
        // qui prendo il popOverPresentationController (ok dopo riga precedente)
        var popoverPC = popoverContent.popoverPresentationController! as UIPopoverPresentationController
        popoverContent.preferredContentSize = CGSizeMake(400, 400);
        popoverPC.delegate = self
        popoverPC.sourceView = self.view
        popoverPC.sourceRect = sender.frame
        popoverPC.passthroughViews = [scrollView];
        
        self.presentViewController(popoverContent, animated: true, completion: nil)
        
    }

    @IBAction func dismissPopover(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //MARK: Popover delegate
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
        
        return true
    }
    
}

