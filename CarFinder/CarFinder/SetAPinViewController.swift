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
    var location = CLLocationCoordinate2D()
    
    
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
        let tempLocation = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        centerMapOnLocation(location: CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
        location = tempLocation
    }
    
    @IBAction func closeNewPin(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {})
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @IBAction func descriptionEditingChanged(_ sender: UITextField) {
        if sender.text != nil {
            descriptionOfPin = sender.text!
        } else {
            descriptionOfPin = ""
        }
    }
    @IBAction func share(_ sender: UIBarButtonItem) {
        if descriptionOfPin != "" {
            let pin = Pin(title: descriptionOfPin, locationName: "location", coordinate:location)
            let shareViewController = self.storyboard?.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
            shareViewController.pin = pin
            self.present(shareViewController, animated: false, completion: nil)
        } else {
            showAlert("Please fill in a description")
        }
    }
    func showAlert(_ message: String) {
        let alertController = UIAlertController(title: "CarFinder", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    
}
