//
//  MapViewController.swift
//  Visits
//
//  Created by Jeffrey Curtis on 4/1/19.
//  Copyright © 2019 Jeffrey Curtis. All rights reserved.
//

import UIKit
import MapKit
import Contacts
class MapViewController: UIViewController {
    let application = UIApplication.shared.delegate as! AppDelegate
    var userLocations = [UserLocation]()
    var userVisits = [UserLocation]()
    
    @IBOutlet weak var mapSegment: UISegmentedControl!
    
    
    @IBAction func maptypeChanged(_ sender: UISegmentedControl) {
        mapView.removeAnnotations(mapView.annotations)
        var placemarks = [MKPlacemark]()
        self.userVisits = application.userVisits
        self.userLocations = application.userLocations
        
        if(sender.selectedSegmentIndex == 0){
            
            for userLocation:UserLocation in userVisits{
                if(userLocation.Latitude == nil || userLocation.Longitude == nil){
                    return;
                }
                let coordinate = CLLocationCoordinate2D.init(latitude: userLocation.Latitude!, longitude: userLocation.Longitude!)
                let userdict = UserLocation.getAddressDict(location: userLocation)
                let mapMarker = MKPlacemark.init(coordinate: coordinate, addressDictionary:userdict)
                print("place --->")
                print(mapMarker)
                placemarks.append(mapMarker)
            }
            
            
        
            mapView.addAnnotations(placemarks)
            
            
        }else if (sender.selectedSegmentIndex == 1){
            
            for userLocation:UserLocation in userLocations{
                print(userLocation)
                if(userLocation.Latitude == nil || userLocation.Longitude == nil){
                    return;
                }
                let coordinate = CLLocationCoordinate2D.init(latitude: userLocation.Latitude!, longitude: userLocation.Longitude!)
                let userdict = UserLocation.getAddressDict(location: userLocation)
                let mapMarker = MKPlacemark.init(coordinate: coordinate, addressDictionary:userdict)
                print("place --->")
                print(mapMarker)
                placemarks.append(mapMarker)
            }
            mapView.addAnnotations(placemarks)

        }else{
            
            for userLocation:UserLocation in userLocations{
                if(userLocation.Latitude == nil || userLocation.Longitude == nil){
                    return;
                }
                let coordinate = CLLocationCoordinate2D.init(latitude: userLocation.Latitude!, longitude: userLocation.Longitude!)
                let userdict = UserLocation.getAddressDict(location: userLocation)
                let mapMarker = MKPlacemark.init(coordinate: coordinate, addressDictionary:userdict)
                print("place --->")
                print(mapMarker)
                placemarks.append(mapMarker)
            }
            mapView.addAnnotations(placemarks)
        
            for userLocation:UserLocation in userVisits{
                if(userLocation.Latitude == nil || userLocation.Longitude == nil){
                    return;
                }
                let coordinate = CLLocationCoordinate2D.init(latitude: userLocation.Latitude!, longitude: userLocation.Longitude!)
                let userdict = UserLocation.getAddressDict(location: userLocation)
                let mapMarker = MKPlacemark.init(coordinate: coordinate, addressDictionary:userdict)
                print("place --->")
                print(mapMarker)
                placemarks.append(mapMarker)
            }
            mapView.addAnnotations(placemarks)
            
        }
        self .updateMapSettings()
    }
    
    @IBOutlet weak var mapTypeSegment: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func mapButtonPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = MKMapType.standard
            break
        case 1:
            mapView.mapType = MKMapType.satellite
            break
        case 2:
            mapView.mapType = MKMapType.hybrid
            break
        case 3:
            mapView.mapType = MKMapType.mutedStandard
            break;
        case 4:
            mapView.mapType = MKMapType.satelliteFlyover 
        default:
            mapView.mapType = MKMapType.mutedStandard
            
        }
    
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = MKMapType.standard
        self.mapSegment.selectedSegmentIndex = 0;
        // register for notifcations on Visit Updates
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(UpdatePlaceMark), name: Notification.Name("VisitPlaceMark"), object: nil)
        var placemarks = [MKPlacemark]()
        mapView.removeAnnotations(mapView.annotations)
        self.userLocations = application.userLocations
        for userLocation:UserLocation in userLocations{
            if(userLocation.Latitude == nil || userLocation.Longitude == nil){
                return;
            }
            let coordinate = CLLocationCoordinate2D.init(latitude: userLocation.Latitude!, longitude: userLocation.Longitude!)
            let userdict = UserLocation.getAddressDict(location: userLocation)
            let mapMarker = MKPlacemark.init(coordinate: coordinate, addressDictionary:userdict)
            print("place --->")
            print(mapMarker)
            placemarks.append(mapMarker)
            
        }
        
        
        
        
        mapView.addAnnotations(placemarks)
        let viewRegion = MKCoordinateRegion(center: placemarks[0].coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(viewRegion, animated: true)
        self .updateMapSettings()
       
    }
    func updateMapSettings(){
        mapView .showsCompass = true
        mapView .showsScale = true
        mapView .showsTraffic = true
        mapView .showsBuildings = true
        mapView .showsPointsOfInterest = true
        
    }
    
    @IBAction func longTap(_ sender: UILongPressGestureRecognizer) {
        print(sender)
        if sender.state == UIGestureRecognizer.State .ended{
        mapView.showsUserLocation = !mapView.showsUserLocation
        }
    }
    @objc func UpdatePlaceMark(_ notification:Notification) {
        var placemarks = [MKPlacemark]()
        mapView.removeAnnotations(mapView.annotations)
        self.userLocations = application.userLocations
        for userLocation:UserLocation in userLocations{
            if(userLocation.Latitude == nil || userLocation.Longitude == nil){
                return;
            }
            let coordinate = CLLocationCoordinate2D.init(latitude: userLocation.Latitude!, longitude: userLocation.Longitude!)
            let userdict = UserLocation.getAddressDict(location: userLocation)
            let mapMarker = MKPlacemark.init(coordinate: coordinate, addressDictionary:userdict)
            print("place --->")
            print(mapMarker)
            placemarks.append(mapMarker)
            
        }
        
        
        
        
        mapView.addAnnotations(placemarks)
        let viewRegion = MKCoordinateRegion(center: placemarks[0].coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(viewRegion, animated: true)
        self .updateMapSettings()
    }    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
