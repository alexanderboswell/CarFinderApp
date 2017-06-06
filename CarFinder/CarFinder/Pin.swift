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
    let locationName: String
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var ref : FIRDatabaseReference?
    
    init( title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, String>
        self.title = data["title"]! as String
        self.locationName = "blah"
        self.coordinate =  CLLocationCoordinate2D(latitude: 38.6223399, longitude: -90.192415)
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(kABPersonAddressStreetKey): subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
}
