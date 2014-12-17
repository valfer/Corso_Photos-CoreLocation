//
//  Photo.swift
//  Parser
//
//  Created by Valerio Ferrucci on 25/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UIImage {
    
    func thumbnail() -> UIImage {
        
        let destinationSize = CGSizeMake(36, 36)
        UIGraphicsBeginImageContext(destinationSize)
        self.drawInRect(CGRectMake(0,0,destinationSize.width,destinationSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

class Photo : NSObject, MKAnnotation {
    
    //MARK: MKAnnotation
    var coordinate: CLLocationCoordinate2D { get {
        
        return CLLocationCoordinate2D(latitude: self.latitudine, longitude: self.longitudine)
        }
    }
    var title: String! { get {
        return self.titolo
        }
    }
    var subtitle: String! { get {
        return self.autore
        }
    }
    
    var image : UIImage?
    var thumb : UIImage?
    
    var titolo : String {
        
        didSet {
            
            self.image = UIImage(named: self.titolo)
            self.thumb = self.image?.thumbnail()
        }
    }
    var autore : String
    var latitudine : Double
    var longitudine : Double
    var data : String
    var descr : String
    var date : NSDate
    
    // se no init -> bug "cannot initialize Photo"
    init(date: NSDate) {
        
        titolo = ""
        autore = ""
        latitudine = 0
        longitudine = 0
        data = ""
        descr = ""
        self.date = date
    }
    
    func description() -> String {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .NoStyle
        let dateFormatted = formatter.stringFromDate(date)

        return dateFormatted + ": " + titolo + "-" + autore
    }
        
}