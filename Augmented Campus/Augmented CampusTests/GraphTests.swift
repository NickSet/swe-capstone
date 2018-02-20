//
//  GraphTests.swift
//  Augmented CampusTests
//
//  Created by Nicholas Setliff on 2/9/18.
//  Copyright © 2018 Nicholas Setliff. All rights reserved.
//

import XCTest
@testable import Augmented_Campus

class GraphTests: XCTestCase {
    
    func testGraphDescription() {
        let graph = Graph<String>()
        
        let a = graph.createNode("a")
        let b = graph.createNode("b")
        let c = graph.createNode("c")
        
        graph.addDirectedEdge(a, to: b, withWeight: 1.0, stairs: false)
        graph.addDirectedEdge(b, to: c, withWeight: 2.0, stairs: true)
        graph.addDirectedEdge(a, to: c, withWeight: -5.5, stairs: true)
        
        let expectedValue = "a -> [(b: 1.0), (A c: -5.5)]\nb -> [(A c: 2.0)]"
        XCTAssertEqual(graph.description, expectedValue)
    }
    
    func testAddingPreexistingNode() {
        let graph = Graph<String>()
        
        let a = graph.createNode("a")
        let b = graph.createNode("a")
            
        XCTAssertEqual(a, b, "Should have returned the same vertex when creating a new one with identical data")
        XCTAssertEqual(graph.nodes.count, 1, "Graph should only contain one vertex after trying to create two vertices with identical data")
    }
    
    func testEdgesFromReturnsCorrectEdgeInSingleEdgeDirecedGraph() {
        
        let graph = Graph<Int>()
        
        let a = graph.createNode(1)
        let b = graph.createNode(2)
        
        graph.addDirectedEdge(a, to: b, withWeight: 1.0)
        
        let edgesFromA = graph.edgesFrom(a)
        let edgesFromB = graph.edgesFrom(b)
        
        XCTAssertEqual(edgesFromA.count, 1)
        XCTAssertEqual(edgesFromB.count, 0)
        
        XCTAssertEqual(edgesFromA.first?.to, b)
    }
    
    func testEdgesFromReturnsCorrectEdgeInSingleEdgeUndirecedGraph() {
        
        let graph = Graph<Int>()
        
        let a = graph.createNode(1)
        let b = graph.createNode(2)
        graph.addUndirectedEdge((a, b), withWeight: 1.0)
        
        let edgesFromA = graph.edgesFrom(a)
        let edgesFromB = graph.edgesFrom(b)
        
        XCTAssertEqual(edgesFromA.count, 1)
        XCTAssertEqual(edgesFromB.count, 1)
        
        XCTAssertEqual(edgesFromA.first?.to, b)
        XCTAssertEqual(edgesFromB.first?.to, a)

    }
    
    func testEdgesFromReturnsNoEdgesInNoEdgeGraph() {
        let graph = Graph<Int>()
        
        let a = graph.createNode(1)
        let b = graph.createNode(2)
        
        XCTAssertEqual(graph.edgesFrom(a).count, 0)
        XCTAssertEqual(graph.edgesFrom(b).count, 0)
    }
    
    func testEdgesFromReturnsCorrectEdgesInBiggerGraphInDirectedGraph() {
        let graph = Graph<Int>()
        let nodeCount = 100
        var nodes: [Node<Int>] = []
        
        for i in 0..<nodeCount {
            nodes.append(graph.createNode(i))
        }
        
        for i in 0..<nodeCount {
            for j in i+1..<nodeCount {
                graph.addDirectedEdge(nodes[i], to: nodes[j], withWeight: 1)
            }
        }
        
        for i in 0..<nodeCount {
            let outEdges = graph.edgesFrom(nodes[i])
            let toNodes = outEdges.map {return $0.to}
            XCTAssertEqual(outEdges.count, nodeCount - i - 1)
            for j in i+1..<nodeCount {
                XCTAssertTrue(toNodes.contains(nodes[j]))
            }
        }
    }
}
