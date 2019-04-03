//
//  MainTableViewController.swift
//  Visits
//
//  Created by Jeffrey Curtis on 3/24/19.
//  Copyright © 2019 Jeffrey Curtis. All rights reserved.
//

import UIKit
import MapKit
import Contacts
class MainTableViewController: UITableViewController {
    let application = UIApplication.shared.delegate as! AppDelegate
    var locationTextCell = LocationTableViewCell()
    
    @IBOutlet weak var mapSegment: UISegmentedControl!

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func setMapType(_ sender: UISegmentedControl) {
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
    @IBAction func vistTypeChanged(_ sender: UISegmentedControl) {
        if(visitTypeSegment.selectedSegmentIndex == 1){
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(self.application.userLocationPlaceMarks)
           
            
        }else{
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(self.application.userVisitPlaceMarks)
            
           
            
        }
        self.tableView .reloadData()
        
    }
    @IBOutlet weak var visitTypeSegment: UISegmentedControl!
    @IBAction func mapButtonPressed(_ sender: UIBarButtonItem){
        let storyBoard = UIStoryboard.init(name: "MapStoryboard", bundle: nil)
        guard let viewController = storyBoard.instantiateInitialViewController() else {
            print("failed")
            return
            
        }
        if let navigator = self.navigationController{
            navigator .pushViewController(viewController, animated: true)
        }
        
        //self .performSegue(withIdentifier: "showMap", sender: self)
    }
    // required overload used when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!UserDefaults.standard.bool(forKey: "locationEnabled")){
            self .performSegue(withIdentifier: "showMain", sender: self)
        }
        mapView.mapType = MKMapType.standard
        self.mapSegment.selectedSegmentIndex = 0;
        // register for notifcations on Visit Updates
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(UpdatePlaceMark), name: Notification.Name("VisitPlaceMark"), object: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // This is a notification posted when a new location is recieved
    // The userInfo contains a dictionary of the location data
    @objc func UpdatePlaceMark(_ notification:Notification) {
        
        if(visitTypeSegment.selectedSegmentIndex == 1){
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(self.application.userLocationPlaceMarks)
            
            self.tableView.reloadData()
            
        }else{
            
        }
        

    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (visitTypeSegment.selectedSegmentIndex == 1){
            return self.application.userLocationPlaceMarks.count
        }else{
            return self.application.userVisitPlaceMarks.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTableViewCell
        print(self.application.userLocations[indexPath.row])
        var place = self.application.userLocationPlaceMarks[indexPath.row]
        
        if (visitTypeSegment.selectedSegmentIndex == 1){
            place = self.application.userLocationPlaceMarks[indexPath.row]
        }else{
            place = self.application.userVisitPlaceMarks[indexPath.row]
        }
        var stringAddress = ""
        
        if let address = place.postalAddress{
            print(address)
            stringAddress = address.street + " " + address.city + " " + " " + address.state + " " + address.postalCode + " " + address.country
            
        }
        
        cell.TopLabel.text = "\(String(describing: place.location!.timestamp))"
        cell.TextView.text = stringAddress
        cell.BottomLabel.text = "Latitude \(place.coordinate.latitude) \n Longitude \(place.coordinate.longitude)"
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard.init(name: "DetailsStoryboard", bundle: nil)
        guard let viewController = storyBoard.instantiateInitialViewController() else {
            print("failed")
            return
            
        }
        if let navigator = self.navigationController{
            navigator .pushViewController(viewController, animated: true)
        }
        
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
