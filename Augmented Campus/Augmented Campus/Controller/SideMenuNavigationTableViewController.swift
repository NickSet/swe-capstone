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
    
    var coordinates = [NavigationLocation]()
    let descriptions = ["Test"]
    var selectedCoordinate = NavigationLocation(lat: 0, lng: 0, name: "", id: -1)
    var selectedDescription = String()
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
        selectedCoordinate = coordinates[indexPath.row]
        selectedDescription = descriptions[indexPath.row]
        performSegue(withIdentifier: "unwindToARViewController", sender: self)
    }
    
    func addCoords() {
        if let destinationTest = graph.getNode(withID: 16) {
            coordinates.append(destinationTest)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                let dT = self.graph.getNode(withID: 16)
                self.coordinates.append(dT!)
            })
        }
    }
}


