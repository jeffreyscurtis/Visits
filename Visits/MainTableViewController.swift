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
    var refreshControler  = UIRefreshControl .init()
    var locationTextCell = LocationTableViewCell()
    let kHeaderHeight:CGFloat = 250
    
    @IBOutlet weak var headerView: UIView!
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

    }
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        if (!UserDefaults.standard.bool(forKey: "locationEnabled")){
            self .performSegue(withIdentifier: "showMain", sender: self)
        }
    }
    // required overload used when view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!UserDefaults.standard.bool(forKey: "locationEnabled")){
            self .performSegue(withIdentifier: "showMain", sender: self)
        }
        if let headerFrame = self.headerView{
            headerFrame.frame.size .height = 250
            self.headerView.frame = headerFrame.frame
        }
  
        mapView.mapType = MKMapType.standard
        self.mapSegment.selectedSegmentIndex = 0;
        // register for notifcations on Visit Updates
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(UpdatePlaceMark),
                       name: Notification.Name("VisitPlaceMark"), object: nil)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        self.tableView.estimatedRowHeight=200;
       
        self.clearsSelectionOnViewWillAppear = false;
        self.tableView.scrollsToTop = true;

        self.tableView.remembersLastFocusedIndexPath = true;
        
        refreshControl?.backgroundColor = self.navigationController?.navigationBar.barTintColor? .withAlphaComponent(0.65)
        mapView.backgroundColor=UIColor .black
        tableView .addSubview(refreshControler)
        self.updateMapSettings()
        self.refreshControl?.backgroundColor = UIColor .clear
        self.refreshControl?.tintColor = self.navigationController?.navigationBar.backgroundColor;
        
        self.refreshControler .addTarget(self, action: #selector(updateLocations), for: UIControl.Event .valueChanged)
        
        
        
        //this is becuase the refreshcontroller is behind the table background
        
        self.refreshControl?.layer.zPosition = (self.tableView.backgroundView?.layer.zPosition)! + 1;
        self.reloadTableData()

    }
    @objc func updateLocations(){
        print("update")
        self.reloadTableData()
        refreshControler .endRefreshing()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let yPos: CGFloat = -scrollView.contentOffset.y
        
        if (yPos > 0) {
            var mapViewRect: CGRect = self.mapView.frame
            mapViewRect.origin.y = scrollView.contentOffset.y
            mapViewRect.size.height = kHeaderHeight+yPos
            self.mapView.frame = mapViewRect
        }}
    
    func updateMapSettings(){
        mapView .showsCompass = true
        mapView .showsScale = true
        mapView .showsTraffic = true
        mapView .showsBuildings = true
        mapView .showsPointsOfInterest = true
        
    }    // This is a notification posted when a new location is recieved
    // The userInfo contains a dictionary of the location data
    @objc func UpdatePlaceMark(_ notification:Notification) {
        
        self .reloadTableData()
        

    }
    func reloadTableData(){
        if(visitTypeSegment.selectedSegmentIndex == 1){
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(self.application.userLocationPlaceMarks)
            
            self.tableView.reloadData()
            
        }else{
            
        }    }
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
        print("<><><><><><><><>")
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
    if we need to use other sizes --
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super .viewWillTransition(to: size, with: coordinator)
        print(size)
        var frame = self.mapView.frame
        frame.size.width = size.width
        mapView.frame=frame
        mapView .setNeedsLayout()
    }
 */
    
    
   
}
