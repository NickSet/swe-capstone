//
//  Building.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/16/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation

class Building {
    //Store all the entrances as node arrays
    var nodes = [NavigationLocation]()
    //Stores the name of the building
    var name: String
    
    //intilization of Building takes NavLoc and stores it in addition to the static name of the building
    init(node: NavigationLocation, name: String) {
        self.nodes.append(node)
        self.name = name
    }
    
    //Adding the NavLoc if a building instance exists
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
