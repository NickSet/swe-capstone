//
//  NavigationLocation.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/6/17.
//  Copyright © 2017 Nicholas Setliff. All rights reserved.
//

import Foundation

final class NavigationLocation {
    var connectedNodes = Set<NavigationLocation>()
    
    let latitude: Double
    let longitude: Double
    let name: String
    let id: Int
    
    init(lat: Double, lng: Double, name: String, id: Int) {
        self.latitude = lat
        self.longitude = lng
        self.name = name
        self.id = id
    }
    
    func makeConnection(to node: NavigationLocation) {
        connectedNodes.insert(node)
    }
    
}

extension NavigationLocation: CustomStringConvertible {
    public var description: String {
        return "\(id): \(name)"
    }
}

extension NavigationLocation: Hashable, Equatable {
    public var hashValue: Int {
        return "\(name)\(id)".hashValue
    }
    
    public static func == (lhs: NavigationLocation, rhs: NavigationLocation) -> Bool {
        guard lhs.latitude == rhs.latitude else {
            return false
        }
        guard lhs.longitude == rhs.longitude else {
            return false
        }
        
        return true
    }
}

extension NavigationLocation: GraphNode {
    func cost(to node: NavigationLocation) -> Double {
        let deltaLat = pow(latitude - node.latitude, 2)
        let deltaLng = pow(longitude - node.longitude, 2)
        
        return (deltaLat + deltaLng).squareRoot()
    }
    
    func estimatedCost(to node: NavigationLocation) -> Double {
        return cost(to: node)
    }
}
