//
//  SlideMenuTableViewController.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 2/13/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class SideMenuNavigationTableViewController: UITableViewController {
    
    var selectedNavLoc = NavigationLocation(lat: 0, lng: 0, name: "", id: -1)
    var graph = DataManager.shared
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graph.buildings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vibrantCell") as! UITableViewVibrantCell
        cell.textLabel?.text = graph.buildings[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Select the shortest route to location
        if let loc = locationManager.location?.coordinate {
            selectedNavLoc = graph.findClosestEntrance(current: loc, buildingEntrances: graph.buildings[indexPath.row].nodes)
        } 
        performSegue(withIdentifier: "unwindToARViewController", sender: self)
    }
}


