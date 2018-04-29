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

/// The view controller that manages the display of our `Building` destinations.
class SideMenuNavigationTableViewController: UITableViewController {
    
    /// The destination location that the user has selected. Is passed back to `ARViewController` through the unwind segue.
    var selectedNavLoc = NavigationLocation(lat: 0, lng: 0, name: "", id: -1)
    /// Singleton instance of the `DataManager` class
    var graph = DataManager.shared
    /// A property to access the `CLLocationManager` properties and methods
    var locationManager = CLLocationManager()
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0)
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    /// Asks the data source to return the number of sections in the table view. In our case, we only have 1 section. Future iterations could break the sections up into different sections of buildings like Classes, Food, Administrative etc.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Tells the data source to return the number of rows in a given section of a table view. In our case, we return the number of `Building` objects our `DataManager` class holds in the `buildings` array.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return graph.buildings.count
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view. In our case, we populate the cell's `textLabel` with the `Building`'s name.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "vibrantCell") as! UITableViewVibrantCell
        cell.textLabel?.text = graph.buildings[indexPath.row].name
        return cell
    }
    
    /// Tells the delegate that the specified row is now selected. Once a destination is selected, we find the closest entrance to that `Building` and then perform the unwind segue to `ARViewController`.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Select the shortest route to location
        if let loc = locationManager.location?.coordinate {
            selectedNavLoc = graph.findClosestEntrance(current: loc, buildingEntrances: graph.buildings[indexPath.row].nodes)
        } 
        performSegue(withIdentifier: "unwindToARViewController", sender: self)
    }
}


