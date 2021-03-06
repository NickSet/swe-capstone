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

/// Singleton class to manage the fetching, updating, and access to FireBase data.
class DataManager {
    /// Closure type used in the `fetchNodes` and `fetchEdges` method
    typealias firebaseClosure = ([String: [String: Any]]?) -> Void
    
    /// Shared object access to the private `DataManager` instance
    static let shared = DataManager()
    
    /// Names of all the buildings on campus
    let buildingNames = [ "Cavalier House",
                          "David J. Prior",
                          "Humphreys-Thomas",
                          "Carl Smith",
                          "Ramseyer Press",
                          "Baptist Collegiate",
                          "Culbertson",
                          "Napolean Hill",
                          "Commonwealth",
                          "Lila Vicars Smith",
                          "McCraray",
                          "Gilliam Center",
                          "Hunter J. Smith",
                          "Thompson",
                          "Papa John's",
                          "Martha Randolph",
                          "Henson Hall",
                          "Library",
                          "Cantrell",
                          "Chapel of All Faiths",
                          "Finacial Aid",
                          "Student Center",
                          "Smiddy",
                          "Mondo's",
                          "Bowers-Sturgill",
                          "Stallard Field",
                          "Fred B. Greer Gym",
                          "Disability Support",
                          "Darden",
                          "Zehmer",
                          "Henson",
                          "Sandridge",
                          "Physical Plant",
                          "Intramural sports",
                          "Observatory",
                          "Alumni Hall",
                          "Wesley Foundation",
                          "Teaching Excellence",
                          "Resource Center",
                          "Women's Softball Field",
                          "Lila Vicars Smith House",
                          "Humphreys Tennis Complex",
                          "Asbury",
                          "Wyllie Hall",
                          "Townhouses",
                          "Sculpture Garden" ]
    
    /// Array of Building objects used in SideMenu
    var buildings: [Building]
    private var navLocations: [Int: NavigationLocation]
    
    /// Private initializer. Only accessible through the static `shared` property.
    private init() {
        navLocations = [:]
        buildings = [Building]()
    }
    
    /// Method to parse NavigationLocations into Building objects
    func initBuildingsArray() {
        //Looping through ALL nodes
        for (_, node) in navLocations {
            //Shortcut, if a node has the word node, it is a connection node. Not a building
            if (node.name.containsIgnoringCase(find: "node")) {
                continue
            } else {
                for buildName in buildingNames {
                    //Comparing each node's description to the string const array of building names
                    if (node.name.containsIgnoringCase(find: buildName)) {
                        //The string matches a buildingName, and must be an entrance
                        if buildings.contains(where: { $0.name == buildName}) {
                            for structure in buildings {
                                if (structure.name == buildName) {
                                    structure.addNavLoc(node)
                                    break;
                                }
                            }
                        } else {
                            let building = Building(node: node, name: buildName)
                            buildings.append(building)
                            break;
                        }
                    }
                }
            }
        }
        // Sort buildings alphabetically
        buildings = buildings.sorted(by: { $0.name < $1.name } )
    }
    
    /// Returns the closest entrance from the destination's entrances to the user
    ///
    /// - Parameter current: the user's current location
    /// - Parameter buildingEntrances: array of building entrances for selected destination
    /// - Returns: the closest entrance to the user's location
    func findClosestEntrance(current: CLLocationCoordinate2D, buildingEntrances: [NavigationLocation]) -> NavigationLocation {
        let locNL = NavigationLocation(lat: current.latitude, lng: current.longitude, name: "", id: -1)
        var distance = Double.infinity
        var closest = NavigationLocation(lat: 0, lng: 0, name: "", id: -1)
        for entrance in buildingEntrances {
            if locNL.cost(to: entrance) > distance {
                continue
            } else {
                closest = entrance
                distance = locNL.cost(to: entrance)
            }
        }
        return closest
    }
    
    /// Returns the closest node to the user's location that is in the graph
    ///
    /// - Parameter current: the user's current location
    /// - Parameter destination: the user's destination
    /// - Returns: the closest node to the user
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
                    closest = x
                }
            }
        }
        return closest
    }
    
    /// Fetches the edges that are available in FireBase
    /// - Parameter completionHandler: A completion handler that takes in a dictionary and returns void, used for not acting on the data until it has been populated.
    public func fetchEdges(completionHandler: @escaping firebaseClosure) {
        let ref: DatabaseReference!
        ref = Database.database().reference()
        var edges: [String: [String: Any]] = [:]
        ref.child("Graph").child("Edges").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: [String: Any]] else {
                return
            }
            edges = dictionary
            
            if edges.isEmpty {
                completionHandler(nil)
            } else {
                completionHandler(edges)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
 
    /// Fetches the nodes that are available in FireBase
    /// - Parameter completionHandler: A completion handler that takes in a dictionary and returns void, used for not acting on the data until it has been populated.
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
    
    /// Converts our JSON Dictionaries into our `NavigationLocation` data structures.
    /// - Parameter nodes: A dictionary of nodes
    /// - Parameter edges: A dictionary of edges
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

    /// Accessor method to get a node with a specific id
    /// - Parameter id: The id of the node you wish to get
    /// - Returns: the node if it exists, otherwise nil.
    public func getNode(withID id: Int) -> NavigationLocation? {
        guard let node = navLocations[id] else {
            return nil
        }
        return node
    }
}

