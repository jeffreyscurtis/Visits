//
//  UserLocation.swift
//  Visits
//
//  Created by Jeffrey Curtis on 3/30/19.
//  Copyright © 2019 Jeffrey Curtis. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import Contacts
struct UserLocation{
    
    private var place: CLPlacemark
    private var location: CLLocation
    
    init (withPlacemark placeMark:CLPlacemark ,andLocation location: CLLocation){
        place = placeMark
        self.location = location
    }
    func getUserLocationDictionary() -> [LocationKeys: Any]{
        
        var userLocationDictionary: [LocationKeys: Any]=[:]
        
        userLocationDictionary[LocationKeys.Latitude] = location.coordinate.latitude
        userLocationDictionary[LocationKeys.Longitude] = location.coordinate.longitude
        userLocationDictionary[LocationKeys.Altitude] = location.altitude
        userLocationDictionary[LocationKeys.Course] = location.course
        userLocationDictionary[LocationKeys.City] = place.locality
        userLocationDictionary[LocationKeys.State] = place.administrativeArea
        userLocationDictionary[LocationKeys.Zip] = place.postalCode
        userLocationDictionary[LocationKeys.Name] = place.name
        userLocationDictionary[LocationKeys.Street] = place.thoroughfare
        userLocationDictionary[LocationKeys.Country] = place.country
        userLocationDictionary[LocationKeys.Info]=place.subLocality
        userLocationDictionary[LocationKeys.Speed]=location.speed
        userLocationDictionary[LocationKeys.Time]=location.timestamp
        userLocationDictionary[LocationKeys.Address] = place.postalAddress
        userLocationDictionary[LocationKeys.AreasOfInterest] = place.areasOfInterest
        userLocationDictionary[LocationKeys.Ocean] = place.ocean
        userLocationDictionary[LocationKeys.InlandWater] = place.inlandWater
        userLocationDictionary[LocationKeys.HorizontalAccuracy] = location.horizontalAccuracy
        userLocationDictionary[LocationKeys.VerticalAccuracy] = location.verticalAccuracy
        userLocationDictionary[LocationKeys.Region] = place.region
        return userLocationDictionary
    
    }
    func getMapMarker()->MKPlacemark{
        let loc = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let placeMark = MKPlacemark(coordinate: loc, postalAddress: place.postalAddress!)
        
        return placeMark
        
    }
    
}

