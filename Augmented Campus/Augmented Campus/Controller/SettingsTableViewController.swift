//
//  SideMenuSettingsViewController.swift
//  Augmented Campus
//
//  Created by Ryan McFadden on 3/6/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import UIKit

/// The view controller that manages the display and interaction of our application's various settings.
class SettingsTableViewController: UITableViewController {

    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source
    /// Asks the data source to return the number of sections in the table view.
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    /// Asks the data source to return the number of sections in the table view.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else {
            return 0
        }
    }
}
