//
//  OrientedGraph.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 11/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

class OrientedGraph: Graph {
    
    var reachabilityList = Array<Array<Int>>()
    var dplus = [Int]()
    var dminus = [Int]()
    
    var StKos = [Int]()
    var label = [Int]()
    
    var reverseGraph: OrientedGraph?
    
    override func initWithString(_ string: String?) {
        super.initWithString(string)
        
        adjList = Array<Array<Int>>()
        
        for _ in 0..<vertices.count { // resize adjacent list of vertices
            adjList.append(Array())
        }
        
        for edge in edges {
            adjList[Int(edge.vertex1.value)! - 1].append(Int(edge.vertex2.value)!)
        }
        
        for _ in 0..<vertices.count { // resize adjacent list of vertices
            dplus.append(0)
            dminus.append(0)
        }
    }
}
