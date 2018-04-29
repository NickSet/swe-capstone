//
//  NavigationLocation.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/6/17.
//  Copyright © 2017 Nicholas Setliff. All rights reserved.
//

import Foundation

/// Object to represent a Node in a graph
final class NavigationLocation {
    /// Set of other graph nodes that this node has an edge leading to.
    var connectedNodes = Set<NavigationLocation>()
    /// The latitude of the node
    let latitude: Double
    /// The longitude of the node
    let longitude: Double
    /// A name for the node. Will either be in the form of "node000" or "The Building's Name"
    let name: String
    /// A unique id integer for this node. Makes node lookup in the O(1) complexity.
    let id: Int
    
    /// Initializer method
    /// - Parameter lat: latitude
    /// - Parameter lng: longitude
    /// - Parameter name: The name of this location
    /// - Parameter id: The locatin's unique id
    init(lat: Double, lng: Double, name: String, id: Int) {
        self.latitude = lat
        self.longitude = lng
        self.name = name
        self.id = id
    }
    
    /// Adds an edge between this instance and node
    /// - Parameter node: The node to make an edge to
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
    /// Required by the `Hashable` protocol. A unique hashable value computed using the `name` and `id` properties
    public var hashValue: Int {
        return "\(name)\(id)".hashValue
    }
    
    /// Required by the `Equatable` protocol. Allows comparisons of two `NavigationLocation`s
    public static func ==(lhs: NavigationLocation, rhs: NavigationLocation) -> Bool {
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
    /// Required by the `GraphNode` protocol
    /// - Parameter node: the destination node
    /// - Returns: the actual cost to reach the indicated node from this node
    func cost(to node: NavigationLocation) -> Double {
        let deltaLat = pow(latitude - node.latitude, 2)
        let deltaLng = pow(longitude - node.longitude, 2)
        
        return (deltaLat + deltaLng).squareRoot()
    }
    
    /// Required by the `GraphNode` protocol.
    /// - Parameter node: the end point of the edge who's cost is to be estimated
    /// - Returns: the estimated heuristic cost to reach the indicated node from this node
    func estimatedCost(to node: NavigationLocation) -> Double {
        return cost(to: node)
    }
}
