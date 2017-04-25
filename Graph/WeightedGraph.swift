//
//  WeightedGraph.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 11/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

struct WeightedEdge: Equatable {
    
    var vertex1: Vertex
    var vertex2: Vertex
    
    var weight: Int
}

func ==(lhs: WeightedEdge, rhs: WeightedEdge) -> Bool {
    return (lhs.vertex1.value == rhs.vertex1.value && lhs.vertex2.value == rhs.vertex2.value) ||
        (lhs.vertex1.value == rhs.vertex2.value && lhs.vertex2.value == rhs.vertex1.value)
}


class WeightedGraph: OrientedGraph {
    
    var weightedEdges = [WeightedEdge]()
   
    var kruskarEdges = [WeightedEdge]()
    var adjWList = Array<Array<(Int, Int)>>()
    var tempAdjWList = Array<Array<(Int, Int)>>()
   
    var markedVertices = [Vertex]()
    var markedEdges = [WeightedEdge]()
    
    override func initWithFileName(_ name: String) -> Bool {
        
        fileName = name
        let text = getStringFromFilePath(name)
        if text == nil {
            return false
        }
        
        if let stringsArray = text {
            
            self.stringsArray = stringsArray
            
            let verticesCount = Int(stringsArray.lines[0]) ?? 0
            
            for _ in 0..<verticesCount { // resize markers array
                markers.append(false)
            }
            
            for _ in 0..<verticesCount { // resize parent array
                parent.append(-1)
            }
            
            for _ in 0..<verticesCount { // resize statuses array
                statuses.append(.new)
            }
            
            for _ in 0..<verticesCount { // resize adjacent list of vertices
                adjList.append(Array())
            }
            
            for _ in 0..<verticesCount { // resize adjacent w list of vertices
                adjWList.append(Array())
            }
            
            for _ in 0..<verticesCount { // resize adjacent matrix
                adjMatrix.append(Array())
            }
            
            let lines = Int(stringsArray.lines[0]) ?? 0
            
            for i in 0..<adjMatrix.count {
                for _ in 0..<lines {
                    adjMatrix[i].append(0)
                }
            }
            
            for i in 0..<stringsArray.lines.count {
                
                if i > 0 {
                    
                    let components = stringsArray.lines[i].components(separatedBy: " ")
                    
                    if components.count < 3 {
                        continue
                    }
                    
                    let a = components[0]
                    let b = components[1]
                    let c = components[2]
                    
                    weightedEdges.append(WeightedEdge(vertex1: Vertex(value: a, degree: 0, degreeIn: 0, degreeOut: 0, isHanging: false, isIsolated: false, isLooped: false, isSource: false, isSink: false, status: .new),
                                                      vertex2: Vertex(value: b, degree: 0, degreeIn: 0, degreeOut: 0, isHanging: false, isIsolated: false, isLooped: false, isSource: false, isSink: false, status: .new),
                                                      
                                                      weight: Int(c)!))
                    
                    if let int_a = Int(a), let int_b = Int(b), let int_c = Int(c) {
                        adjList[int_a - 1].append(int_b)
                        adjWList[int_a - 1].append((int_b, int_c))
                        adjMatrix[int_a - 1][int_b - 1] += 1
                        if int_a == int_b {
                            continue
                        }
                        adjList[int_b - 1].append(int_a)
                        adjWList[int_b - 1].append((int_a, int_c))
                        adjMatrix[int_b - 1][int_a - 1] += 1
                    }
                }
            }
            
            for i in 0..<verticesCount {
                
                var degree: Int = 0
                var isLooped = false
                
                let array = adjList[i]
                degree += array.count
                
                for j in 0..<stringsArray.lines.count {
                    let components = stringsArray.lines[j].components(separatedBy: " ")
                    
                    if j > 0 {
                        
                        if components.count < 2 {
                            continue
                        }
                        
                        let a = components[0]
                        let b = components[1]
                        
                        if let int_a = Int(a), let int_b = Int(b) {
                            if int_a == int_b {
                                if i == int_a - 1 {
                                    degree += 1
                                    isLooped = true
                                }
                            }
                        }
                    }
                }
                
                var v = Vertex(value: "\(i + 1)", degree: degree,  degreeIn: 0, degreeOut: 0,isHanging: false, isIsolated: false, isLooped: isLooped, isSource: false, isSink: false, status: .new)
                
                if degree == 0 {
                    v.isIsolated = true
                } else if degree == 1 {
                    v.isHanging = true
                }
                
                vertices.append(v)
            }
        }
        
        return true
    }
    
    func printWeightedGraph() -> String {
        
        var resultString = ""
        
        for e in weightedEdges {
            resultString.append(e.vertex1.value + " -> " + e.vertex2.value + " (\(e.weight))\n")
        }
        
        return resultString
    }
}
