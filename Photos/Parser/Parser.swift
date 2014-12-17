//
//  Parser.swift
//  Parser
//
//  Created by Valerio Ferrucci on 25/09/14.
//  Copyright (c) 2014 Tabasoft. All rights reserved.
//

import Foundation

// protocoll applicabile solo ad una class (no struct etc), allora posso fare il delegate weak
protocol ParserDelegate : class {
    
    func parserOK(photos : [Photo])
    func parserKO(error : NSError)
}

typealias JSON = AnyObject
typealias JSONDictionary = [String: JSON]
typealias JSONArray = [JSON]

class Parser {
    
    // should be weak
    weak var delegate : ParserDelegate? = nil    // necessario = nil per bug optional default
    
    func start() {
        
        var error : NSError?
        var result : [Photo] = [Photo]()
        
        // parsing
        let filePath : String? = NSBundle.mainBundle().pathForResource("photos", ofType: "json")
        if filePath != nil {
            
            let fileData = NSData(contentsOfFile: filePath!, options:.DataReadingUncached, error: &error)
            // qui andrebbe controllato l'errore nella lettura del file
            
            let json : AnyObject? = NSJSONSerialization.JSONObjectWithData(fileData!, options: NSJSONReadingOptions(0), error: &error)
            
            if let _json = json as? [AnyObject] {
                
                for jsonItem in _json {
                
                    if let _jsonItem = jsonItem as? JSONDictionary {
                        
                        let titolo : JSON? = _jsonItem["titolo"]
                        let autore : JSON? = _jsonItem["autore"]
                        let latitudine : JSON? = _jsonItem["latitudine"]
                        let longitudine : JSON? = _jsonItem["longitudine"]
                        let data : JSON? = _jsonItem["data"]
                        let descr : JSON? = _jsonItem["descr"]
                        
                        if let _titolo = titolo as String? {
                            if let _autore = autore as? String {
                                if let _latitudine = latitudine as? Double {
                                    if let _longitudine = longitudine as? Double {
                                        if let _data = data as? String {
                                            if let _descr = descr as? String {
                                                
                                                let photo = Photo(date: dateFromString(_data))
                                                photo.titolo = _titolo
                                                photo.autore = _autore
                                                photo.latitudine = _latitudine
                                                photo.longitudine = _longitudine
                                                photo.data = _data
                                                photo.descr = _descr
                                                
                                                result.append(photo)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // ordiniamo discendente
                    result.sort({ (photo1 : Photo, photo2 : Photo) -> Bool in
                        
                        return photo1.date.compare(photo2.date) == NSComparisonResult.OrderedDescending
                    })
                }
            } else {
                
                error = NSError(domain: "Parser", code: 101, userInfo: [NSLocalizedDescriptionKey:"Il parser JSON è fallito"])
            }

            
        } else {
            
            error = NSError(domain: "Parser", code: 101, userInfo: [NSLocalizedDescriptionKey:"La ricerca del file path è fallita"])
        }
        
        // chiama il delegate (se settato)
        if let _delegate = delegate {
            
            if let _error = error {
                _delegate.parserKO(_error)
            } else {
                var dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3))
                dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                    
                    _delegate.parserOK(result)
                }
            }
        }
    }

    func dateFromString(dateStr : String) -> NSDate {
        
        let dateStrArray = dateStr.componentsSeparatedByString("-")
        let dateComp = NSDateComponents()
        
        /*
        Da notare che l'array tornato da componentsSeparatedByString
        contiene NSNumber (oggetti) e non int, quindi chiamiamo intValue
        */
        dateComp.day = dateStrArray[0].toInt()!
        dateComp.month = dateStrArray[1].toInt()!
        dateComp.year = dateStrArray[2].toInt()!
        
        let gregorian = NSCalendar(identifier:NSGregorianCalendar)
        let date : NSDate! = gregorian!.dateFromComponents(dateComp)
        
        return date
    }
}
