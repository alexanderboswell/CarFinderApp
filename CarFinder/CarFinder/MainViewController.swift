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
import MapKit

class MainViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var pins = TempSingleton.sharedInstance.pins
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        // set initial location of the mapview
        let initialLocation = CLLocation(latitude: 38.623283, longitude: -90.190816)
        centerMapOnLocation(location: initialLocation)
        for pin in pins {
            mapView.addAnnotation(pin)
        }
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)

    }

    @IBAction func signOut(_ sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            assertionFailure("Error signing out: \(error)")
        }
        signOut()
    }
    func signOut() {
        performSegue(withIdentifier: "signOutSegue", sender: nil)
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
