//
//  SetAPinViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/15/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SetAPinViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var descriptionOfPin = ""
    var location = CLLocation()
    
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
       // print("locations = \(locValue.latitude) \(locValue.longitude)")
        location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        centerMapOnLocation(location: location)
    }
    
    @IBAction func closeNewPin(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {});
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        let pin = Pin(title: "Busch Stadium",
                      locationName: "Cardinals Baseball Stadium",
                      coordinate: CLLocationCoordinate2D(latitude: 38.6223399, longitude: -90.192415))
        
        mapView.addAnnotation(pin)
    }
    @IBAction func descriptionEditingChanged(_ sender: UITextField) {
        if sender.text != nil {
            descriptionOfPin = sender.text!
        } else {
            descriptionOfPin = ""
        }
    }
    @IBAction func share(_ sender: UIBarButtonItem) {
        print ("TESTING")
        print(descriptionOfPin)
        print(location)
        performSegue(withIdentifier: "setAPinToShare", sender: nil)
    }

    
}
