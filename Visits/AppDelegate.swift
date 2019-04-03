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
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var locationEnabled = UserDefaults.standard.bool(forKey: "locationEnabled")
    let locationManager = CLLocationManager()
    
    //location data structures
    var userLocationPlaceMarks = [MKPlacemark]()
    var userLocations = [UserLocation]()
    
    //visit data structures
    var userVisits = [CLVisit]()
    var userVisitsWithDetails = [UserLocation]()
    var userVisitPlaceMarks = [MKPlacemark]()
    
    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager .allowsBackgroundLocationUpdates = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        locationEnabled = UserDefaults.standard.bool(forKey: "locationEnabled")
        print("App from backgrounf " + locationEnabled.description)
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
            // we dont want these
        }else{
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
                        
                        let place = UserLocation(withPlacemark: firstPlacemark, andLocation: location)
                        let userLocationDict = place.getUserLocationDictionary()
                        //add placemarks and userlocation to app array , this needs to go to a database instead
                        //we are inserting at 0 so the most recent location is removed first in table view
                        self.userVisitPlaceMarks.insert(place.getMapMarker(), at: 0)
                        self.userVisitsWithDetails.insert(place, at: 0)
                        let nc = NotificationCenter.default
                        nc.post(name: Notification.Name("VisitsPlaceMark"), object: nil, userInfo: userLocationDict)
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
                
                // Most geocoding requests contain only one result.
                if let firstPlacemark = placemarks?.first {
                    
                    let place = UserLocation(withPlacemark: firstPlacemark, andLocation: location)
                    let userLocationDict = place.getUserLocationDictionary()
                    //add placemarks and userlocation to app array , this needs to go to a database instead
                    //we are inserting at 0 so the most recent location is removed first in table view
                    self.userLocationPlaceMarks.insert(place.getMapMarker(), at: 0)
                    self.userLocations.insert(place, at: 0)
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("VisitPlaceMark"), object: nil, userInfo: userLocationDict)
                }
                //debug print
                print(location)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
            print("restricted")
            break
            
        case .authorizedWhenInUse:
            print("only allowed while running")
            // Enable basic location features
            //enableMyWhenInUseFeatures()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            locationManager .startMonitoringSignificantLocationChanges()
            
            // locationManager .startUpdatingLocation()
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

