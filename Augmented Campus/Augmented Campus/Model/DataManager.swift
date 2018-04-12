//
//  DataManager.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/10/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class DataManager {
    typealias firebaseClosure = ([String: [String: Any]]?) -> Void
    
    /**
    Shared object access to the private `DataManager` instance
    */
    static let shared = DataManager()
    
    private var navLocations: [Int: NavigationLocation]
    
    private init() {
        navLocations = [:]
    }
    
    func findClosest(current: CLLocationCoordinate2D, destination: NavigationLocation) -> NavigationLocation {
        let temp = NavigationLocation(lat: current.latitude, lng: current.longitude, name: "", id: -1)
        var distance = 99999.9
        var closest = temp //declaring an "empty" value
        var temp2: Double
        for (_,x) in navLocations {
            if x == destination {
                //if destination's distance is short enough, don't do this
                continue
            } else if x.cost(to: destination) > temp.cost(to: destination) {
                continue
            } else {
                temp2 = temp.cost(to:x)
                if(temp2 < distance){
                    distance = temp2
                    closest = xß
                }
            }
        }
        return closest
    }
    
    public func fetchEdges(completionHandler: @escaping firebaseClosure) {
        let ref: DatabaseReference!
        ref = Database.database().reference()
        var edges: [String: [String: Any]] = [:]
        ref.child("Graph").child("Edges").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                return
            }
            edges = dictionary
            //self.convertToNavigationLocations(from: dictionary)
            if edges.isEmpty {
                completionHandler(nil)
            } else {
                completionHandler(edges)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
 
    public func fetchNodes(completionHandler: @escaping firebaseClosure) {
        let ref: DatabaseReference!
        ref = Database.database().reference()
        var nodes: [String: [String: Any]] = [:]
        ref.child("Graph").child("Nodes").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                return
            }
            nodes = dictionary
            if nodes.isEmpty {
                completionHandler(nil)
            } else {
                completionHandler(nodes)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func convertToNavigationLocations(nodes: [String: [String: Any]],
                                              edges: [String: [String: Any]]) {
        for node in nodes.values {
            let id = node["_id"] as! Int
            let lat = node["latitude"] as! Double
            let lng = node["longitude"] as! Double
            let dsc = node["description"] as! String
            let navLoc = NavigationLocation(lat: lat, lng: lng, name: dsc, id: id)
            
            navLocations[id] = navLoc
        }
        
        for edge in edges.values {
            let from = edge["from"] as! Int
            let to = edge["to"] as! Int
            navLocations[from]!.makeConnection(to: navLocations[to]!)
        }
    }

    public func getNode(withID id: Int) -> NavigationLocation? {
        guard let node = navLocations[id] else {
            return nil
        }
        return node
    }
}

