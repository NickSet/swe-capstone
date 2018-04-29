//
//  Building.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/16/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation

/// Object used for storing our destination locations and their entrances
class Building {
    
    /// An array containing this Building's entrances
    var nodes = [NavigationLocation]()
    
    /// The name of this building. Used to populate the navigation menu.
    var name: String
    
    //intilization of Building takes NavLoc and stores it in addition to the static name of the building
    init(node: NavigationLocation, name: String) {
        self.nodes.append(node)
        self.name = name
    }
    
    /// Add's a NavigationLocation to the nodes array
    ///
    /// - Parameter node: the NavigationLocation to add
    func addNavLoc(_ node: NavigationLocation) {
        nodes.append(node)
    }
}

//Easier printing for sideout menu
extension Building: CustomStringConvertible {
    public var description: String {
        return "\(name)"
    }
}
