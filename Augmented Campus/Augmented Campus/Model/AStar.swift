//
//  AStarV2.swift
//  Augmented Campus
//
//  Created by SWE Capstone on 3/8/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation
import CoreLocation

class AStar {
    var graph: Graph<CLLocationCoordinate2D>
    var fGraph: Graph<CLLocationCoordinate2D>
    
    init(withGraph graph: Graph<CLLocationCoordinate2D>, andFGraph fGraph: Graph<CLLocationCoordinate2D>) {
        // set fGraph's startLocation fScore to 0
        self.graph = graph
        self.fGraph = fGraph
    }
    
    func findPathToB(startLocation: Node<CLLocationCoordinate2D>, endLocation: Node<CLLocationCoordinate2D>) -> [Node<CLLocationCoordinate2D>] {
        var current = startLocation //This imports it for the first time. It'll be updated continuously from here in the following while loop.
        
        var closedSet = [Node<CLLocationCoordinate2D>]()
        var openSet = [Node<CLLocationCoordinate2D>]()
        
        openSet.append(current)
        
        
        var cameFrom = [Node<CLLocationCoordinate2D>]()
        cameFrom.append(current)
        
        var gScore = [String: Double]()
        gScore[current.description] = 0
        
        var tentativeGScore = Double()
        
        while !openSet.isEmpty {
            current = lowestFScore(openSet: openSet)
            
            if current == endLocation {
                return cameFrom
            }
            
            if openSet.contains(current) {
                if let index = openSet.index(of: current) {
                    openSet.remove(at: index)
                }
            }
            
            for neighbor in graph.edgesFrom(current) {
                if let _ = gScore.index(forKey: neighbor.description) {
                    gScore[neighbor.description] = 99999.1
                }
                
                
                if closedSet.contains(current) {
                    continue
                }
                
                if !openSet.contains(current) {
                    openSet.append(current)
                }
                
                tentativeGScore = gScore[current.description]! + neighbor.weight!
                if tentativeGScore >= gScore[neighbor.description]! {
                    continue
                }
                
                cameFrom.append(current)
                gScore[neighbor.description] = tentativeGScore
                //Add fscore to fgraph custom data stuff
                //neighbor.to.index = gScore[neighbor.description] + getEstimatedValue(neighbor, endLocation)
            }
            
            
            closedSet.append(current)
        }
    }
    
    func lowestFScore(openSet: [Node<CLLocationCoordinate2D>]) -> Node<CLLocationCoordinate2D> {
        var lowestNode = openSet[0]
        for node in openSet {
            if node.index < lowestNode.index {
                lowestNode = node
            }
        }
        return lowestNode
    }
    
    func getEstimatedValue(current: Node<CLLocationCoordinate2D, goal: Node<CLLocationCoordinate2D>) -> Double {
        //This is the pythagorean theorem using the GPS location to find the distance. This is the "heuristics" part
    }

    
}
