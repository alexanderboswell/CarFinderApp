//
//  Pin.swift
//  CarFinder
//
//  Created by alexander boswell on 5/16/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import MapKit
import AddressBook
import FirebaseDatabase

class Pin : NSObject, MKAnnotation {
    
    // MARK: Class variables
    let locationName: String
    let title: String?
    
    let latitude: Double?
    
    let longitude: Double?
    
    let coordinate: CLLocationCoordinate2D
    
    var ref : FIRDatabaseReference?
    
    var subtitle: String? {
        return locationName
    }
    //MARK: Initizalition
    init( title: String, locationName: String, latitude: Double, longitude: Double) {
        self.title = title
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        super.init()
    }
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, Any>
        
        self.title = data["title"]! as? String
        self.locationName = data["locationName"]! as! String
        self.latitude = data["latitude"]! as! NSNumber as? Double
        self.longitude = data["longitude"]! as! NSNumber as? Double
        self.coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        super.init()
    }
    
    // MARK: Class functions
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}
