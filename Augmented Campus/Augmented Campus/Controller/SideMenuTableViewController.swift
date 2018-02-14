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

class SideMenuTableViewController: UITableViewController {
    
    var coordinates = [CLLocationCoordinate2D]()
    var selectedCoordinate = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCoords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh cell blur effect in case it changed
        tableView.reloadData()
        
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        
        cell.blurEffectStyle = SideMenuManager.default.menuBlurEffectStyle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "unwindToARViewController", sender: self)
        selectedCoordinate = coordinates[indexPath.row]
    }
    
    func addCoords() {
        let fountain = CLLocationCoordinate2D(latitude: 36.971647, longitude:  -82.558558)
        let lake = CLLocationCoordinate2D(latitude: 36.971875, longitude: -82.561650)
        let entrance = CLLocationCoordinate2D(latitude: 36.969963, longitude: -82.560619)
        
        coordinates.append(fountain)
        coordinates.append(lake)
        coordinates.append(entrance)
    }
    
}
