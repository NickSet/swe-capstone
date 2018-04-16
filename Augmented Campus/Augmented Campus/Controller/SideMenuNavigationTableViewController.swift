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
    
    var navigationLocations = [NavigationLocation]()
    let descriptions = ["Node 16"]
    var selectedNavLoc = NavigationLocation(lat: 0, lng: 0, name: "", id: -1)
    var graph = DataManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCoords()
        tableView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNavLoc = navigationLocations[indexPath.row]
        performSegue(withIdentifier: "unwindToARViewController", sender: self)
    }
    
    func addCoords() {
        if let destinationTest = graph.getNode(withID: 248) {
            navigationLocations.append(destinationTest)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                let dT = self.graph.getNode(withID: 248)
                self.navigationLocations.append(dT!)
            })
        }
    }
}


