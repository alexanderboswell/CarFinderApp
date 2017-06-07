//
//  MainViewController.swift
//  CarFinder
//
//  Created by alexander boswell on 5/6/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
//    var pins = TempSingleton.sharedInstance.pins
    var pins = [Pin]()
    
    // FireBase varibales
    var user: FIRUser!
    
    var databasePins = [Pin]()
    
    var ref: FIRDatabaseReference!
    
    private var databaseHandle: FIRDatabaseHandle!
    
    let locationManager = CLLocationManager()
    
    var centerLocation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up Firebase
        user = FIRAuth.auth()?.currentUser
        ref = FIRDatabase.database().reference()
        startObservingDatabase()
        
        mapView.delegate = self

        // set up side menu
        if self.revealViewController() != nil {

            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        // set up configuration for showing user location
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView.showsUserLocation = true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        _ = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        if centerLocation {
            centerMapOnLocation(location: CLLocation(latitude: locValue.latitude, longitude: locValue.longitude))
            centerLocation = false
        }
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

    }
    func resetAnotations(){
        mapView.removeAnnotations(mapView.annotations)
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }

    func startObservingDatabase () {
        databaseHandle = ref.child("users/\(self.user.uid)/pins").observe(.value, with: { (snapshot) in
            var newPins = [Pin]()
            for itemSnapShot in snapshot.children {
                let pin = Pin(snapshot: itemSnapShot as! FIRDataSnapshot)
                newPins.append(pin)
            }
            
            self.pins = newPins
            self.tableView.reloadData()
            self.resetAnotations()
            
        })
    }
    
    deinit {
        ref.child("users/\(self.user.uid)/pins").removeObserver(withHandle: databaseHandle)
        }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pins.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = "PinTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PinTableViewCell  else {
                fatalError("The dequeued cell is not an instance of PinTableViewCell.")
            }

            cell.titleLabel.text = pins[indexPath.row].title
            cell.subTitleLabel.text = pins[indexPath.row].locationName
            return cell
            
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source

            let pin = pins[indexPath.row]
            pins.remove(at: indexPath.row)
            pin.ref?.removeValue()
            tableView.deleteRows(at: [indexPath], with: .fade)
            for annotation in mapView.annotations {
                if let aTitle = annotation.title, let pinTitle = pin.title, let aSub = annotation.subtitle, let pinSub = pin.subtitle {
                if aTitle! == pinTitle && aSub == pinSub {
                    mapView.removeAnnotation(annotation)
                }
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pin = pins[(indexPath.row)]
        centerMapOnLocation( location: CLLocation(latitude: pin.coordinate.latitude, longitude: pin.coordinate.longitude))
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}
