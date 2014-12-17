//
//  PhotoSplitViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 08/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit

class PhotoSplitViewController : UISplitViewController, UISplitViewControllerDelegate {

    //var masterPopover : UIPopoverController? = nil
    //var barButtonItem : UIBarButtonItem? = nil

    override func viewDidLoad() {
        
        self.preferredDisplayMode = .Automatic // .PrimaryOverlay  //.AllVisible
        self.delegate = self
    }

    // will hide, will show
    /*
    DEPRECATED

    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController) {
        
        // salvo popover e barButton
        barButtonItem.title = "Photos"  // torno alla lista photos
        self.barButtonItem = barButtonItem
        self.masterPopover = pc
    }
    
    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        
        // levo popover e barButton
        self.masterPopover = nil
        self.barButtonItem = nil
    }
    */
    
    //MARK: - UISplit Delegate
    
    // questa va settata quando seleziono una foto
    var selectedPhoto : Int? = nil
    
    /* When the split expands, it sets its current (and only) vc as the new primary. If you want to set another vc ad the primary, return it from this method */
    func primaryViewControllerForExpandingSplitViewController(splitViewController: UISplitViewController!) -> UIViewController! {
        
        return nil
    }
    
    /* When the split collapses it uses its current primary vc as the new single vc. If you want it to set a different vc as the new vc, return it from this method */
    func primaryViewControllerForCollapsingSplitViewController(splitViewController: UISplitViewController!) -> UIViewController! {
        
        return nil
    }
    
    /* This is called just before the split is collapsing. If this method return false, the split calls the primary's method "collapseSecondaryViewController:forSplitViewController" to give it a chance to do something with the secondary VC (who is disappearing). i.e. the NavigationController uses collapseSecondaryViewController:forSplitViewController to push the secondary as the new primary.
    
    If return true the split does nothing and the primary will be the single vc */
    func splitViewController(splitViewController: UISplitViewController!, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        
        // if no photo selected, leave the primary as the main vc
        return selectedPhoto == nil
    }
    
    /* When the split expands and this method return nil the split calls the primary VC method "separateSecondaryViewControllerForSplitViewController" to obtain the new secondary (the NavigationController reutrn the last vc popped from the stack as the new secondary), otherwise it uses this VC as the new secondary */
    func splitViewController(splitViewController: UISplitViewController!, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController!) -> UIViewController! {
        
        if selectedPhoto != nil {
            return nil
        } else {
            // if no photo selected, push an empty secondary
            return PhotoViewController()    // uno vuoto
        }
    }

}
