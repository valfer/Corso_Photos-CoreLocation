//
//  PhotoInfoViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 05/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit

class PhotoInfoViewController : UIViewController {
    
    //MARK: Info change
    @IBOutlet weak var infoTextView: UITextView!
    
    private func setNewInfoText() {
        
        if let _info = info {
            if let _infoTextView = infoTextView {     // outlet già settato?
                _infoTextView.text = _info
            }
        }
    }
    var info : String? = nil {
        
        didSet {
            
            setNewInfoText()
        }
    }

    //MARK: Life Cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setNewInfoText()
    }
    // oppure
    @IBAction func closeInfo(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

}
