//
//  TempSingleton.swift
//  CarFinder
//
//  Created by alexander boswell on 5/22/17.
//  Copyright © 2017 alexander boswell. All rights reserved.
//

import Foundation
import MapKit

class TempSingleton: NSObject {
    var pins:[Pin] = []
    var users:[User] = []
    static let sharedInstance = TempSingleton()
    override init() {
        var pin = Pin(title: "Busch Stadium", locationName: "Cardinals Baseball Stadium", coordinate: CLLocationCoordinate2D(latitude: 38.6223399, longitude: -90.192415))
        pins.append(pin)
        pin = Pin(title: "Gateway Arch", locationName: "St Louis momument", coordinate: CLLocationCoordinate2D(latitude: 38.624754, longitude: -90.184908))
        pins.append(pin)
        pin = Pin(title: "City Museum", locationName: "Best Museum, ever.", coordinate: CLLocationCoordinate2D(latitude: 38.633188, longitude: -90.200173))
        pins.append(pin)
        var user = User(username: "Alex")
        users.append(user)
        user = User(username: "Hannah")
        users.append(user)
        user = User(username : "Louis")
        users.append(user)        
    }
}
