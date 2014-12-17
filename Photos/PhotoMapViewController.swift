//
//  PhotoMapViewController.swift
//  Photos
//
//  Created by Valerio Ferrucci on 09/09/14.
//  Copyright (c) 2014 Valerio Ferrucci. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController : UIViewController, MKMapViewDelegate {
    
    var locManager : CLLocationManager!
    
    let kAnnotationIdentifier = "MapPhotoPin"
    
    var photo : Photo? {
        
        didSet {
            prepareMap()
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    func prepareMap() {
        
        if let _photo = photo {
            if let _mapView = mapView {
            
                _mapView.addAnnotation(_photo)
                
                // posiziono la mappa in modo da far vedere le annotation
                _mapView.showAnnotations(_mapView.annotations, animated: true)

                if false {
                    
                    let ground = CLLocationCoordinate2DMake(_photo.latitudine, _photo.longitudine)
                    let eye = CLLocationCoordinate2DMake(_photo.latitudine, _photo.longitudine)
                    let myCamera = MKMapCamera(
                        lookingAtCenterCoordinate: ground,
                        fromEyeCoordinate: eye,
                        eyeAltitude: 30)
                    //myCamera.pitch = 45
                    /*
                    N.B: il pitch gesture con due dita funziona solo se la mappa è tipo Standard
                    */
                    
                    mapView.setCamera(myCamera, animated: false)
                }
                
                // proviamo directions
                showDirections()
            }
        }
    }
    
    func showDirections() {
        
        // faccio un geocode reverse sulla photo
        let geocoder = CLGeocoder()
        let photoLocation = CLLocation(latitude: photo!.coordinate.latitude, longitude: photo!.coordinate.longitude)
        geocoder.reverseGeocodeLocation(photoLocation, completionHandler: { (placemarks:[AnyObject]!, error : NSError!) -> Void in
            
            // qui check errore!
            
            let photoPlaceMark = placemarks[0] as CLPlacemark
            println(photoPlaceMark.addressDictionary)
            
            let directionsRequest = MKDirectionsRequest()
            directionsRequest.setSource(MKMapItem.mapItemForCurrentLocation())
            let placemark = MKPlacemark(placemark: photoPlaceMark)
            directionsRequest.setDestination(MKMapItem(placemark: placemark))
            
            // finalmente
            let directions = MKDirections(request: directionsRequest)
            
            directions.calculateDirectionsWithCompletionHandler({ (response : MKDirectionsResponse?, error : NSError!) -> Void in

                
                if let _response = response {
                    
                    let route =  _response.routes[0] as MKRoute
                    let poly = route.polyline   // MKPolyline
                    self.mapView.addOverlay(poly)
                    
                    for step in route.steps as [MKRouteStep]{
                    
                        println("\(step.distance) m \(step.instructions)")
                    }
                    
                } else {
                    println("error calculating directions \(error)")
                }

            })
        })
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        // questo serve solo per la richiesta di consenso privacy location
        locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()

        mapView.delegate = self
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.showsUserLocation = true
        mapView.pitchEnabled = true
        mapView.showsBuildings = true;
        mapView.mapType = .Hybrid   //.Satellite    //.Standard

        if false {
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2DMake(43.065, 11.725),
                span: MKCoordinateSpanMake(1, 1))
            mapView.setRegion(region, animated:false)
            
            let finalRegion = mapView.regionThatFits(region)
            
            // area di 100x100 metri
            let from = CLLocationCoordinate2DMake(43.065, 11.725)
            let degreesRegion = MKCoordinateRegionMakeWithDistance(from, 100, 100)
        }

        prepareMap()

    }

    //MARK: Altri opzionali
    override func viewWillAppear(animated: Bool) {
        
        if false {

            // open in Map App
            let photoPlaceMark = MKPlacemark(coordinate: photo!.coordinate, addressDictionary: nil)
            let photoMapItem = MKMapItem(placemark: photoPlaceMark)
            photoMapItem.name = "Questa è la mia foto"
            let span = NSValue(MKCoordinateSpan:self.mapView.region.span)
            photoMapItem.openInMapsWithLaunchOptions([MKLaunchOptionsMapTypeKey : MKMapType.Hybrid.rawValue,
                MKLaunchOptionsMapSpanKey : span])
        }
        
        if false {

            // forward geocode
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString("Lungarno Francesco Ferrucci 25, Firenze", completionHandler: { (placemarks : [AnyObject]!, error : NSError!) -> Void in
                
                for pm in placemarks as [CLPlacemark] {
                    
                    let mkPlacemark = MKPlacemark(placemark: pm)
                    self.mapView.addAnnotation(mkPlacemark)
                    println(mkPlacemark)
                }
                
            })
            
        }
        
        if false {
            
            // local search
            let searchRequest = MKLocalSearchRequest()
            searchRequest.naturalLanguageQuery = "Ristorante Indiano"
            searchRequest.region = mapView.region
            let localSearch = MKLocalSearch(request: searchRequest)
            localSearch.startWithCompletionHandler({ (response : MKLocalSearchResponse!, error : NSError!) -> Void in
                
                if let _response = response {
                    
                    let mapItem : MKMapItem = _response.mapItems[0] as MKMapItem
                    
                    mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsMapTypeKey : MKMapType.Hybrid.rawValue])
                    
                } else {
                
                    println(error)
                }
            })
        }
    }
    
    //MARK: Delegate
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        let polyRender = MKPolylineRenderer(overlay: overlay!)
        polyRender.strokeColor = UIColor.blueColor()
        polyRender.lineWidth = 2
        
        return polyRender
    }
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        
        mapView.showAnnotations(mapView.annotations, animated: true)

    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        
        var customPinView : MKAnnotationView?
        
        if annotation is MKUserLocation == false {
            
            if annotation is Photo {
                
                customPinView = mapView.dequeueReusableAnnotationViewWithIdentifier(kAnnotationIdentifier)
                if customPinView == nil {
                    
                    // lo dobbiamo allocare
                    customPinView = MKAnnotationView(annotation: annotation, reuseIdentifier: kAnnotationIdentifier)
                    let photo = annotation as Photo
                    customPinView!.image = photo.thumb
                    customPinView!.bounds = CGRectMake(0, 0, 20, 20)
                    customPinView!.centerOffset = CGPointMake(0, -20)
                    customPinView!.canShowCallout = true
                } else {
                    customPinView?.image = photo?.thumb
                }
                customPinView?.annotation = photo
            }
            
        }
        
        return customPinView
    }
}
