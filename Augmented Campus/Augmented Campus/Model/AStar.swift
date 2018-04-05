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
    var graph: Graph<NavigationLocation>
    
    init(withGraph graph: Graph<NavigationLocation>) {
        // set fGraph's startLocation fScore to 0
        self.graph = graph
    }
    
    func findPathToB(startLocation: Node<NavigationLocation>, endLocation: Node<NavigationLocation>) -> [Node<NavigationLocation>]{
        var current = startLocation //This imports it for the first time. It'll be updated continuously from here in the following while loop.
        
        var closedSet = [Node<NavigationLocation>]()
        var openSet = [Node<NavigationLocation>]()
        
        openSet.append(startLocation) //Initializes the open set with the start location value for initial traversal.
        
        
        var cameFrom = [Node<NavigationLocation>]()
        cameFrom.append(current) //starts from the start location. initializes start.
        

        
        var tentativeGScore = Double() //temporary storage of value before it gets put into the array.
        
        while !openSet.isEmpty {
            //implement: start node contains the initial location
            current = lowestFScore(openSet: openSet) //Finds the "root node" to traverse from for this portion
            
            if current == endLocation { //if the end result is where we currently are, stop.
                return findRealPathToB(startLocation: startLocation, endLocation: endLocation)
            }
            
            if openSet.contains(current) { //If the openSet contains the current value, ala the root node of the current piece of the traversal.
                if let index = openSet.index(of: current) { //removes the piece from the openset.
                    openSet.remove(at: index)
                }
            }
            
            for var neighbor in graph.edgesFrom(current) { //Starts the traversal from one edge to another
                //"neighbor" is a localized name for edge
                if let _ = current.data.gScore{
                    current.data.gScore = 99999.1
                }
                if closedSet.contains(current) { //if the value is located in the closed set, skip the current value. That's all this does.
                    continue
                }
                
                if !openSet.contains(current) { //add new value to the open set
                    openSet.append(current)
                }
                
                tentativeGScore = current.data.gScore! + neighbor.weight! //temporary gScore
                if tentativeGScore >= neighbor.to.data.gScore! { //If the current distance is greater than the combination of the neighbor's distance, stop.
                    continue
                }
                
                cameFrom.append(current)
                
                
                //Changing the distance of the destination of the neighbor to become the distance from start to said neighbor.
                neighbor.to.data.gScore = tentativeGScore
                
                
                
                //Add fscore
                neighbor.to.data.fScore = neighbor.to.data.gScore! + getEstimatedValue(current: neighbor.to, goal: endLocation)
                
                if !openSet.contains(neighbor.to){
                    openSet.append(neighbor.to)
                }
            }
            
            
            closedSet.append(current)
        }
        let result = findRealPathToB(startLocation: startLocation, endLocation: endLocation) //replace this with the result of cameFrom
        return result
    }
    
    //This one traverses the graph after a precomputation is done.
    func findRealPathToB(startLocation: Node<NavigationLocation>, endLocation: Node<NavigationLocation>) -> [Node<NavigationLocation>]{
        var current = startLocation //This imports it for the first time. It'll be updated continuously from here in the following while loop.
        
        var closedSet = [Node<NavigationLocation>]()
        var openSet = [Node<NavigationLocation>]()
        
        openSet.append(startLocation) //Initializes the open set with the start location value for initial traversal.
        
        
        var cameFrom = [Node<NavigationLocation>]()
        cameFrom.append(current) //starts from the start location. initializes start.
        
        
        
        var tentativeGScore = Double() //temporary storage of value before it gets put into the array.
        
        while !openSet.isEmpty {
            //implement: start node contains the initial location
            current = lowestFScore(openSet: openSet) //Finds the "root node" to traverse from for this portion
            
            if current == endLocation { //if the end result is where we currently are, stop.
                return cameFrom
            }
            
            if openSet.contains(current) { //If the openSet contains the current value, ala the root node of the current piece of the traversal.
                if let index = openSet.index(of: current) { //removes the piece from the openset.
                    openSet.remove(at: index)
                }
            }
            
            for var neighbor in graph.edgesFrom(current) { //Starts the traversal from one edge to another
                //"neighbor" is a localized name for edge

                if closedSet.contains(current) { //if the value is located in the closed set, skip the current value. That's all this does.
                    continue
                }
                
                if !openSet.contains(current) { //add new value to the open set
                    openSet.append(current)
                }
                
                tentativeGScore = current.data.gScore! + neighbor.weight! //temporary gScore
                if tentativeGScore >= neighbor.to.data.gScore! { //If the current distance is greater than the combination of the neighbor's distance, stop.
                    continue
                }
                
                cameFrom.append(current)
                

                //Changing the distance of the destination of the neighbor to become the distance from start to said neighbor.
                neighbor.to.data.gScore = tentativeGScore
                
                
                
                //Add fscore
                neighbor.to.data.fScore = neighbor.to.data.gScore! + getEstimatedValue(current: neighbor.to, goal: endLocation)
                
                //neighbor.to.index = gScore[neighbor.description] + getEstimatedValue(neighbor, endLocation)
                if !openSet.contains(neighbor.to){
                    openSet.append(neighbor.to)
                }
            }
            
            
            closedSet.append(current)
        }
        return cameFrom
    }
    
    func lowestFScore(openSet: [Node<NavigationLocation>]) -> Node<NavigationLocation> {
        var lowestNode = openSet[0]
        for node in openSet {
            if node.index < lowestNode.index {
                lowestNode = node
            }
        }
        return lowestNode
    }
    
    func getEstimatedValue(current: Node<NavigationLocation>, goal: Node<NavigationLocation>) -> Double {
        var num1 = 0.0 //stupid errors
        var num2 = 0.0
        var num3 = 0.0
        num1 = (current.data.latitude * current.data.latitude)
        num2 = (current.data.longitude * current.data.longitude)
        num3 = num1 + num2
        return num3.squareRoot()

    }

    
}
