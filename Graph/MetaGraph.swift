//
//  MetaGraph.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 11/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

struct VertexWithInfo {
    
    var value: String
    var edgesTo = [Edge]()
}

struct MetaVertex {
    
    var number: Int
    var vertices: [VertexWithInfo]
}

class MetaGraph {
    
    var vertices = [MetaVertex]()
    var edges = [Edge]()
    
    var adjList = Array<Array<Int>>()
    var statuses = [VertexStatus]()
    
    func initWithComponents(components: [Int], edges: [Edge]) {
        
        self.edges = edges
        
        for i in 0..<components.count {
            
            var existVertex = false
            
            for v in vertices {
                if v.number == components[i] {
                    existVertex = true
                    break
                }
            }
            
            if !existVertex {
                vertices.append(MetaVertex(number: components[i], vertices: [VertexWithInfo(value: "\(i + 1)", edgesTo: [Edge]())]))
            } else {
                
                for j in 0..<vertices.count {
                    if vertices[j].number == components[i] {
                        vertices[j].vertices.append(VertexWithInfo(value: "\(i + 1)", edgesTo: [Edge]()))
                    }
                }
            }
        }
        
        for _ in vertices {
            adjList.append(Array())
        }
    }
    
    func printMetagraph() {
        
        for i in 0..<vertices.count {
            print("Вершина \(vertices[i].number): (", terminator: " ")
            for j in vertices[i].vertices {
                print(j.value, terminator: " ")
            }
            print(")")
        }
        
        for i in 0..<vertices.count {
            var v1 = vertices[i]
            
            for j in 0..<v1.vertices.count {
                var v2 = v1.vertices[j]
                
                for e in edges {
                    if e.vertex1.value == v2.value {
                        v2.edgesTo.append(e)
                    }
                }
                
                v1.vertices[j] = v2
            }
            
            vertices[i] = v1
        }
        
        
        for i in 0..<vertices.count {
            let v = vertices[i]
            let currentMetaNumber = v.number
            
            for v2 in v.vertices {
                for e in v2.edgesTo {
                    
                    let adj = isInComponents(exceptNumber: currentMetaNumber, value: e.vertex2.value)
                    
                    for a in adj {
                        
                        var exist = false
                        
                        for x in adjList[i] {
                            if x == a {
                                exist = true
                                break
                            }
                        }
                        
                        if !exist {
                            adjList[i].append(a)
                        }
                    }
                }
            }
        }
        
        print("\nСписки смежности:\n")
        
        for i in 0..<adjList.count {
            print("Вершина \(vertices[i].number):", terminator: " ")
            
            for j in adjList[i] {
                print("\(j)", terminator: " ")
            }
            
            print("")
        }
    }
    
    func isInComponents(exceptNumber: Int, value: String) -> [Int] {
        
        var linkedMetaVertices = [Int]()
        
        for v in vertices {
            if v.number != exceptNumber {
                
                for v2 in v.vertices {
                    if v2.value == value {
                        linkedMetaVertices.append(v.number)
                    }
                }
            }
        }
        
        return linkedMetaVertices
    }
}
