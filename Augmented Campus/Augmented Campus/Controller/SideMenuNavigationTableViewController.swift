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
    
    var coordinates = [CLLocationCoordinate2D]()
    let descriptions = ["Fountain", "Lake", "Entrance"]
    var selectedCoordinate = CLLocationCoordinate2D()
    var selectedDescription = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCoords()
        tableView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        
        cell.blurEffectStyle = SideMenuManager.default.menuBlurEffectStyle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCoordinate = coordinates[indexPath.row]
        selectedDescription = descriptions[indexPath.row]
        performSegue(withIdentifier: "unwindToARViewController", sender: self)
    }
    
    func addCoords() {
        let fountain = CLLocationCoordinate2D(latitude: 36.971647, longitude:  -82.558557) 
        let lake = CLLocationCoordinate2D(latitude: 36.971875, longitude: -82.561650)
        let entrance = CLLocationCoordinate2D(latitude: 36.969963, longitude: -82.560619)
        
        coordinates.append(fountain)
        coordinates.append(lake)
        coordinates.append(entrance)
    }
    
}
