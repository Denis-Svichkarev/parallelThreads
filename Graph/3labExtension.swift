//
//  3labExtension.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 10/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

extension OrientedGraph {

    // MARK: - 1 Task
    
    func printTieredForm() {
        
        calculateSemiDegrees()
        
        var levels = [[String]]()
        var vertices_copy = vertices
        
        
        while vertices_copy.count > 0 {
            
            var vertices_copy2 = [Vertex]()
            
            var level = [String]()
            
            for v in vertices_copy {
                if v.degreeIn == 0 {
                    level.append(v.value)
                } else {
                    vertices_copy2.append(v)
                }
            }
            
            levels.append(level)
            
            for i in 0..<vertices_copy2.count {
                
                var vertex = vertices_copy2[i]
                
                for e in edges {
                    
                    var isOnLevel = false
                    
                    for v in level {
                        if v == e.vertex1.value {
                            isOnLevel = true
                            break
                        }
                    }
                    
                    if !isOnLevel { continue }
                    
                    if e.vertex1.degree == 0 && e.vertex2.value == vertex.value {
                        vertex.degreeIn -= 1
                    }
                }
                
                vertices_copy2[i] = vertex
            }
            
            vertices_copy = vertices_copy2
            
            for i in 0..<edges.count {
                
                var edge = edges[i]
                
                for v in vertices_copy {
                    if v.value == edge.vertex1.value {
                        edge.vertex1.degree = v.degree
                    }
                    
                    if v.value == edge.vertex2.value {
                        edge.vertex2.degree = v.degree
                    }
                }
            }
            
        }
        
        for i in 0..<levels.count {
            let level = levels[i]
            
            print("\(i) уровень:", terminator: " ")
            for v in level {
                print(v, terminator: " ")
            }
            
            print("");
        }
    }
    
    // MARK: - 2 Task
    
    func printStrongLinkedComponents() {
    
        unmark()
        createReverseGraph()
        
        for i in 1..<vertices.count {
            
            if !markers[i - 1] {
                revPushDFS(v: i)
            }
            
            unmark()
            
            var count = 0
            
            while !StKos.isEmpty {
                let v = StKos.last
                StKos.removeLast()
                
                if !markers[v! - 1] {
                    count += 1
                    labelOneDFS(v: v!, count: count)
                }
            }
        }
    }
    
    func revPushDFS(v: Int) {
        
        if let reverseGraph = reverseGraph {
            
            markers[v - 1] = true
            for u in reverseGraph.adjList[v - 1] {
                if !markers[u - 1] {
                    revPushDFS(v: u)
                }
                StKos.append(v)
            }
        }
    }
    
    func labelOneDFS(v: Int, count: Int) {
        markers[v - 1] = true
        labels[v - 1] = count
        
        for w in adjList[v - 1] {
            if !markers[w - 1] {
                labelOneDFS(v: w, count: count)
            }
        }
    }
    
    func createReverseGraph() {
        
        let string = generateInputTextStringWithEdges(edges: edges)
        var reverseString = ""
        
        for i in 0..<string.lines.count {
        
            let components = string.lines[i].components(separatedBy: " ")
            
            if components.count == 1 {
                let a = components[0]
                reverseString.append(a + "\n")
                continue
            }
            
            let a = components[0]
            let b = components[1]
            
            reverseString.append(b + " " + a + "\n")
        }

        reverseGraph = OrientedGraph()
        reverseGraph?.initWithString(reverseString)
    }
}

extension MetaGraph {
    
    // MARK: - 3 Task
    
    func checkIfAcyclicGraph() {
        
        statuses = [VertexStatus]()
        
        for _ in 0..<vertices.count {
            statuses.append(.new)
        }
        
        print("\nПроверка метаграфа на ацикличность:\n")
        
        let isAcyclic = isAcyclicDFS(v: vertices[0].number)
        
        if isAcyclic {
            print("Метаграф ацикличен")
        } else {
            print("Метаграф цикличен")
        }
    }
    
    func isAcyclicDFS(v: Int) -> Bool {
        
        statuses[v - 1] = .active
        
        for w in adjList[v - 1] {
            switch statuses[w - 1] {
            case .active:
                return false
            case .new:
                if !isAcyclicDFS(v: w) {
                    return false
                }
            default : break
            }
        }
        
        statuses[v - 1] = .done
        return true
    }
}
