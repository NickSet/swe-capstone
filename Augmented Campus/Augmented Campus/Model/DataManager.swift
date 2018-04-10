//
//  DataManager.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/10/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation
import Firebase

class DataManager {
    typealias firebaseClosure = ([String: [String: Any]]?) -> Void
    
    /**
    Shared object access to the private `DataManager` instance
    */
    static let shared = DataManager()
    
    
    private var navLocations: [Int: NavigationLocation] = [:]
    
    private init() {
        var nodesDict = [String: [String: Any]]()
        var edgesDict = [String: [String: Any]]()
        fetchNodes(completionHandler: { nodes in
            nodesDict = nodes!
            self.fetchEdges(completionHandler: { edges in
                edgesDict = edges!
                self.convertToNavigationLocations(nodes: nodesDict, edges: edgesDict)
            })
        })
    }
    
    private func fetchEdges(completionHandler: @escaping firebaseClosure) {
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
 
    private func fetchNodes(completionHandler: @escaping firebaseClosure) {
        let ref: DatabaseReference!
        ref = Database.database().reference()
        var nodes: [String: [String: Any]] = [:]
        ref.child("Graph").child("Nodes").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                return
            }
            nodes = dictionary
            //self.convertToNavigationLocations(from: dictionary)
            if nodes.isEmpty {
                completionHandler(nil)
            } else {
                completionHandler(nodes)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    private func convertToNavigationLocations(nodes: [String: [String: Any]],
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
        
        for (key, value) in navLocations {
            print(value)
        }
    }

    public func getNode(withID id: Int) -> NavigationLocation? {
        guard let node = navLocations[id] else {
            return nil
        }
        return node
    }
}

