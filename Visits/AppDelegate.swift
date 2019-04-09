//
//  AppDelegate.swift
//  Visits
//
//  Created by Jeffrey Curtis on 3/24/19.
//  Copyright © 2019 Jeffrey Curtis. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import MapKit
import Contacts
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    /// persistant store semiphore
    var locationEnabled = UserDefaults.standard.bool(forKey: "locationEnabled")
    /// Location manager for the location services
    let locationManager = CLLocationManager()
    
    /// location data structures
    /// this is an array of Map Placemarks -- used currently to update values
    var userLocationPlaceMarks = [MKPlacemark]()
    /// this is the array of UserLocations will be used to update the tables
    var userLocations = [UserLocation]()
    
    
    /// visit data structures
    var userVisits = [CLVisit]()
    var userVisitsWithDetails = [UserVisit]()
    var userVisitPlaceMarks = [MKPlacemark]()
    
    var window: UIWindow?
    
    /// Required function called when application has finshed loading
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        locationManager.delegate = self
        locationManager .allowsBackgroundLocationUpdates = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
            if self.userLocations.writeJSONData() ?? false{
                print("User data has been written to 'UserLocation.json'")
            }else{
                print("User data has failed.")
            }
    
        
        
        
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.userLocations.readJSONData();
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        locationEnabled = UserDefaults.standard.bool(forKey: "locationEnabled")
        print("App from background " + locationEnabled.description)
        if locationEnabled{
            locationManager.delegate = self
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                // Request when-in-use authorization initially
              
                break
                
            case .restricted, .denied:
                // Disable location features
                //disableMyLocationBasedFeatures()
                break
                
            case .authorizedWhenInUse:
                // Enable basic location features
                //enableMyWhenInUseFeatures()
                break
                
            case .authorizedAlways:
                // Enable any of your app's location features
                //enableMyAlwaysFeatures()
                //locationManager .startUpdatingLocation()
                locationManager.startMonitoringVisits()
                locationManager.startMonitoringSignificantLocationChanges()
                break
            @unknown default:
              print("failed")
            }
            
        }
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        print("got visit")
        if(visit.departureDate==NSDate.distantFuture || visit.arrivalDate == NSDate.distantPast){
            // we dont want these as the visits are only half visists
        }else{
            //
            self.userVisits.insert(visit, at: 0);
            let location = CLLocation .init(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                    
                    // Most geocoding requests contain only one result.
                    if let firstPlacemark = placemarks?.first {
                        //create structure
                        var place = UserVisit()

                        let userLocationDictionary = UserVisit.getUserLocationDictionary(place: firstPlacemark, andLocation: location, andVisit: visit)
                        
                        //add placemarks and userlocation to app array , this needs to go to a database instead
                        //we are inserting at 0 so the most recent location is removed first in table view
                        self.userVisitPlaceMarks.insert(UserVisit.getMapMarker(location: location, place: firstPlacemark), at: 0)
                        self.userVisitsWithDetails.insert(place, at: 0)
                        
                        place.Latitude = userLocationDictionary[LocationKeys.Latitude] as? Double
                        place.Longitude = userLocationDictionary[LocationKeys.Longitude] as? Double
                        place.Street = userLocationDictionary[LocationKeys.Street] as? String
                        place.SubLocality = userLocationDictionary[LocationKeys.Info] as? String
                        place.City = userLocationDictionary[LocationKeys.City] as? String
                        place.State = userLocationDictionary[LocationKeys.State] as? String
                        place.Postalcode = userLocationDictionary[LocationKeys.Zip] as? String
                        place.Country = userLocationDictionary[LocationKeys.Country] as? String
                        place.CountryCode = userLocationDictionary[LocationKeys.Zip] as? String
                        place.Altitude = userLocationDictionary[LocationKeys.Altitude] as? Double
                        place.Course = userLocationDictionary[LocationKeys.Course] as? Double
                        place.AdministrativeArea = userLocationDictionary[LocationKeys.State] as? String
                        place.Name = userLocationDictionary[LocationKeys.Name] as? String
                        place.Info = userLocationDictionary[LocationKeys.Info] as? String
                        place.Speed = userLocationDictionary[LocationKeys.Speed] as? Double
                        place.Time = userLocationDictionary[LocationKeys.Time] as? Date
                        place.Address = userLocationDictionary[LocationKeys.Address] as? String
                        place.AreasOfInterest = userLocationDictionary[LocationKeys.AreasOfInterest] as? [String]
                        place.Ocean = userLocationDictionary[LocationKeys.Ocean] as? String
                        place.InlandWater = userLocationDictionary[LocationKeys.InlandWater] as? String
                        place.HorizontalAccuracy = userLocationDictionary[LocationKeys.HorizontalAccuracy] as? Double
                        place.VerticalAccuracy = userLocationDictionary[LocationKeys.VerticalAccuracy] as? Double
                        place.UID = UUID.init()
                        
                        
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("VisitsPlaceMark"), object: nil, userInfo: userLocationDictionary)
                    }
                    //debug print
                    print(location)
                }
            
        }
            
        
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("got update")
        let geocoder = CLGeocoder()
        for location in locations{
           
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                /// Most geocoding requests contain only one result.
                if let firstPlacemark = placemarks?.first {
                    
                   
                    
                    /// create a dictionary form the placemark and location
                    let userLocationDictionary = UserLocation .getUserLocationDictionary(place: firstPlacemark, andLocation: location)
                   
                    /// create a map marker and add to the array
                    self.userLocationPlaceMarks.insert(UserLocation.getMapMarker(location: location, place: firstPlacemark), at: 0)
                    /// create the userLocation struct
                    var place = UserLocation .init()
                    
                    place.Latitude = userLocationDictionary[LocationKeys.Latitude] as? Double
                    place.Longitude = userLocationDictionary[LocationKeys.Longitude] as? Double
                    place.Street = userLocationDictionary[LocationKeys.Street] as? String
                    place.SubLocality = userLocationDictionary[LocationKeys.Info] as? String
                    place.City = userLocationDictionary[LocationKeys.City] as? String
                    place.State = userLocationDictionary[LocationKeys.State] as? String
                    place.Postalcode = userLocationDictionary[LocationKeys.Zip] as? String
                    place.Country = userLocationDictionary[LocationKeys.Country] as? String
                    place.CountryCode = userLocationDictionary[LocationKeys.Zip] as? String
                    place.Altitude = userLocationDictionary[LocationKeys.Altitude] as? Double
                    place.Course = userLocationDictionary[LocationKeys.Course] as? Double
                    place.AdministrativeArea = userLocationDictionary[LocationKeys.State] as? String
                    place.Name = userLocationDictionary[LocationKeys.Name] as? String
                    place.Info = userLocationDictionary[LocationKeys.Info] as? String
                    place.Speed = userLocationDictionary[LocationKeys.Speed] as? Double
                    place.Time = userLocationDictionary[LocationKeys.Time] as? Date
                    place.Address = userLocationDictionary[LocationKeys.Address] as? String
                    place.AreasOfInterest = userLocationDictionary[LocationKeys.AreasOfInterest] as? [String]
                    place.Ocean = userLocationDictionary[LocationKeys.Ocean] as? String
                    place.InlandWater = userLocationDictionary[LocationKeys.InlandWater] as? String
                    place.HorizontalAccuracy = userLocationDictionary[LocationKeys.HorizontalAccuracy] as? Double
                    place.VerticalAccuracy = userLocationDictionary[LocationKeys.VerticalAccuracy] as? Double
                    place.UID = UUID.init()
                    //test to write array of json
                    self.userLocations .insert(place, at: 0)
                    
                 
                
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("VisitPlaceMark"), object: nil, userInfo: userLocationDictionary)
                   
                    // let userData = place.writeJSONData()
                    
                    // Error handling.
                    /*
                    if (userData == true){
                        print("User data has been written to 'UserLocation.json'")
                    } else {
                        print("User data has failed.")
                    }*/
                    
                }
                //debug print
                print(location)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let nc = NotificationCenter.default
        switch CLLocationManager.authorizationStatus() {
           
        case .notDetermined:
            // Request when-in-use authorization initially
            print("not determined")
            if(self.locationEnabled){
                locationManager.requestAlwaysAuthorization()
            }
            break
            
        case .restricted, .denied:
            // Disable location features
            //disableMyLocationBasedFeatures()
            nc.post(name: Notification.Name("LocationErrorSetting"), object: nil, userInfo: nil)
            print("restricted")
            break
            
        case .authorizedWhenInUse:
            print("only allowed while running")
           
            nc.post(name: Notification.Name("LocationErrorSetting"), object: nil, userInfo: nil)
            
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            locationManager .startMonitoringSignificantLocationChanges()
            
           
            locationManager .startMonitoringVisits()
            UserDefaults.standard.set(true, forKey: "locationEnabled")
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("LocationEnabled"), object: nil)
            break
        @unknown default:
            print("Fail")
            break
            
        }
        
    }


}

extension Decodable{
    
    func readJSONData() ->Bool{
        var fileRead = false
        
        let file = "UsersLocations.json" // file to store user data.
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            do {
            
                // appends file to directory path.
                let fileURL = dir.appendingPathComponent(file)
                print(fileURL.path) //prints out the file path to where the data is being store.
                let data = try Data(contentsOf: fileURL)
                
                
                let decoder = JSONDecoder()
                let JSONData = try decoder.decode([UserLocation].self, from: data)
                
                print(JSONData)
            
    
            } catch {
                print(error)
            }
        }
        return fileRead
    }
}
// encode to Json and write data to file.
extension Encodable {
    func writeJSONData() -> Bool? {
        let encoder = JSONEncoder() // Json encoder object.
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(self) else { return false } //encodes the data that is passed to writeJSONData function.
        let file = "UsersLocations.json" // file to store user data.
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            // appends file to directory path.
            let fileURL = dir.appendingPathComponent(file)
            
            print("Writing to file... \n")
            //let fileManager = FileManager.default
            print(fileURL.path)
            
            do{
                try jsonData.write(to: fileURL)
                return true;
                
                
            }catch{
                print("Failed to write date")
                return false
            }
            
        }
        return false
    }
}
