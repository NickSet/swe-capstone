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
    
    func testSwift4() {
        // last checked with Xcode 9.0b4
        #if swift(>=4.0)
            print("Hello, Swift 4!")
        #endif
    }
    
    func testAdjacencyListGraphDescription() {
        
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
    
}
