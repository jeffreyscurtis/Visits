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
    @IBOutlet weak var mapSegment: UISegmentedControl!
    
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
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(application.userPlaceMarks)
      
        let viewRegion = MKCoordinateRegion(center: application.userPlaceMarks[0].coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(viewRegion, animated: false)
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
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(application.userPlaceMarks)
        let viewRegion = MKCoordinateRegion(center: application.userPlaceMarks[0].coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
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
