//
//  GraphNode.swift
//  Augmented Campus
//
//  Created by Nicholas Setliff on 4/6/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import Foundation

/// Declares the requirements for optimal pathfinding in a directed graph of nodes and the implementation of the A* algorithm.
public protocol GraphNode: Hashable {    
    /**
     * List of other graph nodes that this node has an edge leading to.
     */
    var connectedNodes: Set<Self> { get }
    
    /// Returns the estimated heuristic cost to reach the indicated node from this node
    ///
    /// - Parameter node: the end point of the edge who's cost is to be estimated
    /// - Returns: the heuristic cost
    func estimatedCost(to node: Self) -> Double
    
    /// - Parameter node: the destination node
    /// - Returns: the actual cost to reach the indicated node from this node
    func cost(to node: Self) -> Double
    
}


class Step<Node: GraphNode> {
    var node: Node
    var previous: Step<Node>?
    
    var stepCost: Double
    var goalCost: Double
    
    init(from start: Node, to destination: Node, goal: Node) {
        node = destination
        stepCost = start.cost(to: destination)
        goalCost = destination.estimatedCost(to: goal)
    }
    
    init(destination: Node, previous: Step<Node>, goal: Node) {
        (node, self.previous) = (destination, previous)
        stepCost = previous.stepCost + previous.node.cost(to: destination)
        goalCost = destination.estimatedCost(to: goal)
    }
    
    func cost() -> Double {
        return stepCost + goalCost
    }
    
}


extension Step: Hashable, Equatable, Comparable {
    var hashValue: Int {
        return node.hashValue
    }
    
    static func ==(lhs: Step, rhs: Step) -> Bool {
        return lhs.node == rhs.node
    }
    
    public static func <(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() < rhs.cost()
    }
    
    public static func <=(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() <= rhs.cost()
    }
    
    public static func >=(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() >= rhs.cost()
    }
    
    public static func >(lhs: Step, rhs: Step) -> Bool {
        return lhs.cost() > rhs.cost()
    }
    
}


extension GraphNode {
    /// Attempts to find the optimal path between this node and the indicated goal node.
    /// If such a path exists, it is returned in start to end order.
    /// If it doesn't exist, the array returned will be empty.
    ///
    /// - Parameter goalNode: the goal node of the pathfinding attempt
    /// - Returns: the optimal path between this node and the indicated goal node
    public func findPath(to goalNode: Self) -> [Self] {
        var possibleSteps = [Step<Self>]()
        var eliminatedNodes: Set = [self]
        
        for connectedNode in connectedNodes {
            let step = Step(from: self, to: connectedNode, goal: goalNode)
            possibleSteps.sortedInsert(newElement: step)
        }
        
        var path = [self]
        while !possibleSteps.isEmpty {
            let step = possibleSteps.removeFirst()
            if step.node == goalNode {
                var cursor = step
                path.insert(step.node, at: 1)
                while let previous = cursor.previous {
                    cursor = previous
                    path.insert(previous.node, at: 1)
                }
                break
            }
            eliminatedNodes.insert(step.node)
            let nextNodes = step.node.connectedNodes.subtracting(eliminatedNodes)
            for node in nextNodes {
                let nextStep = Step(destination: node, previous: step, goal: goalNode)
                let index = possibleSteps.binarySearch(element: nextStep)
                if index < possibleSteps.count && possibleSteps[index] == nextStep {
                    if nextStep.stepCost < possibleSteps[index].stepCost {
                        possibleSteps[index].previous = step
                    }
                } else {
                    possibleSteps.sortedInsert(newElement: nextStep)
                }
            }
        }
        return path
    }
    
    
    /// As with findPathToNode: except this node is the goal node and a startNode is specified
    ///
    /// - Parameter startNode: the start node of the pathfinding attempt
    /// - Returns: the optimal path between the indicated start node and this node
    public func findPath(from startNode: Self) -> [Self] {
        return startNode.findPath(to: self)
    }
}

