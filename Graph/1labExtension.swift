//
//  GraphExtension.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 04/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

extension Graph {
    
    // MARK: - 1 Task
    
    func printAdjList() {
        
        if vertices.count == 0 {
            print("У графа нет смежных вершин")
            return
        }
        
        print("Список смежных вершин:")
        
        for i in 0..<vertices.count {
            print("\nВершина", terminator:" ")
            vertices[i].printVertex()
            print(":", terminator:" ")
            for item in adjList[i] {
                print("\(item)", terminator:" ")
            }
        }
    }
    
    func printAdjMatrix() {
        
        print("\n\nМатрица смежности:\n")
        
        for i in 0..<vertices.count {
            for item in adjMatrix[i] {
                print("\(item)", terminator:" ")
            }
            print("")
        }
    }
    
    func printLinkedComponents() {
        
        for i in 0..<markers.count {
            if markers[i] == true {
                print("\(i + 1)", terminator:" ")
            }
        }
    }
    
    // MARK: - 2 Task
    
    func printDegreeVertices() {
        
        print("2.1 Степени вершин:")
        
        for vertex in vertices {
            vertex.printVertexWithDegree()
        }
        
        print("")
    }
    
    func printIsolatedVertices() {
        
        print("\n2.2 Список изолированных вершин:\n")
        
        for vertex in vertices {
            if vertex.isIsolated {
                vertex.printVertex()
            }
        }
        
        print("")
    }
    
    func printHangingVertices() {
        
        print("\n2.3 Список висячих вершин:\n")

        for vertex in vertices {
            if vertex.isHanging {
                vertex.printVertex()
            }
        }
        
        print("")
    }
    
    func printHangingEdges() {
        
        print("\n2.4 Список висячих ребер:\n")
        
        var hangingEdges = [Edge]()
        
        for vertex in vertices {
            
            if vertex.isHanging {
                for edge in edges {
                    if edge.vertex1.value == vertex.value || edge.vertex2.value == vertex.value {
                        hangingEdges.append(edge)
                        continue
                    }
                }
            }
        }
        
        for edge in hangingEdges {
            edge.printEdge()
        }
    }
    
    func printLoopedVertices() {
        
        print("\n2.5 Список вершин с петлями:\n")
        
        for vertex in vertices {
            if vertex.isLooped {
                vertex.printVertex()
            }
        }
        
        print("")
    }
    
    func printMultipleEdges() {
        
        print("\n2.6 Список кратных ребер:\n")
        
        let testEdges = edges
        
        for i in 0..<testEdges.count {
            
            var degree = 0
            
            for j in 0..<testEdges.count {
                
                if i == j {
                    continue
                }
                
                let edge1 = testEdges[i]
                let edge2 = testEdges[j]
                
                if (edge1.vertex1.value == edge2.vertex1.value && edge1.vertex2.value == edge2.vertex2.value) || (edge1.vertex1.value == edge2.vertex2.value && edge1.vertex2.value == edge2.vertex1.value) {
                    degree += 1
                }
            }
            
            edges[i].degree = degree
        }

        for edge in edges {
            if edge.degree > 0 {
                edge.printEdgeWithDegree()
            }
        }
    }
    
    // MARK: - 3 Task
    
    func getSimpleGraph() -> Graph {
    
        var nonloopedEdges = [Edge]()
        
        for i in 0..<edges.count {
            if !edges[i].isLooped() {
                nonloopedEdges.append(edges[i])
            }
        }
        
        var nonmultipleEdges = [Edge]()
        
        for edge in nonloopedEdges {
            if !hasEdges(edges: nonmultipleEdges, edge: edge) {
                nonmultipleEdges.append(edge)
            }
        }
        
        let text = generateInputTextStringWithEdges(edges: nonmultipleEdges)
     
        let simpleGraph = Graph()
        simpleGraph.initWithString(text)
        return simpleGraph
    }
    
    func generateInputTextStringWithEdges(edges: [Edge]) -> String {
        
        var text = ""
        
        var newVertices = [Vertex]()
        
        for edge in edges {
            if !hasVertex(vertices: newVertices, vertex: edge.vertex1) {
                newVertices.append(edge.vertex1)
            }
            
            if !hasVertex(vertices: newVertices, vertex: edge.vertex2) {
                newVertices.append(edge.vertex2)
            }
        }
        
        text.append("\(getMaxVertexValue(vertices: newVertices))\n")
        
        for edge in edges {
            text.append(edge.vertex1.value + " " + edge.vertex2.value + "\n")
        }
        
        return text
    }
    
    // MARK: - 4 Task
    
    func printLinkedComponentsOfSimpleGraph() {
    
        linkedComponets = getLinkedComponents()
        
        for c in linkedComponets {
            print(c)
        }
    }
    
    func getLinkedComponents() -> Array<Array<String>> {
        
        var components = Array<Array<String>>()
        
        unmark()
        
        for v in vertices {
            var component = [String]()
            recursiveDFS(v: Int(v.value)!, printSpanningTree: false, component: &component)
            
            if component.count > 0 {
                components.append(component)
            }
        }
        
        return components
    }
    
    func getLinkedComponentsCount() -> Int {
        unmark()
        var count = 0
        
        for i in 0..<vertices.count {
            if markers[i] == true {
                continue
            }
            count += 1
            var component = [String]()
            recursiveDFS(v: i + 1, printSpanningTree: false, component: &component)
        }
        
        return count
    }
    
    // MARK: - 5 Task
    
    func recursiveDFS(v: Int, printSpanningTree: Bool, component: inout [String]) {
        
        if v > markers.count {
            return
        }
        
        if markers[v - 1] == true {
            return
        }
        
        component.append("\(v)")
        
        if printSpanningTree { print("'\(v)'", terminator:" ") }
        
        markers[v - 1] = true
        
        for i in 0..<adjList[v - 1].count {
            recursiveDFS(v: adjList[v - 1][i], printSpanningTree: printSpanningTree, component: &component)
        }
    }
    
    func BFS(vertices: [String]) {
        
        var markedVertices = [(value: String, marked: Bool)]()

        for i in 0..<vertices.count {
            markedVertices.append((vertices[i], false))
        }
        
        var queue = [(value: String, marked: Bool)]()
        
        markedVertices[0].marked = true
        queue.append(markedVertices[0])
        
        print("#" + markedVertices[0].value, terminator: " ")
        
        repeat {
            
            let index = queue[0].value
            queue.remove(at: 0)
            
            for i in adjList[Int(index)! - 1] {
                
                var marked = false
                
                for v in markedVertices {
                    if v.value == "\(i)" {
                        if v.marked == true {
                            marked = true
                            break
                        }
                    }
                }
                
                if !marked {
                    queue.append(("\(i)", true))
                    
                    var index = -1
                    for m in 0..<markedVertices.count {
                        if markedVertices[m].value == "\(i)" {
                            index = m
                            break
                        }
                    }
                    
                    if index != -1 {
                        markedVertices[index].marked = true
                        print("#" + markedVertices[index].value, terminator: " ")
                    }
                }
            }
            
        } while queue.count != 0
    }
    
    func unmark() {
        markers.removeAll()
        
        for _ in 0..<vertices.count {
            markers.append(false)
        }
    }
    
    // MARK: - Helpers
    
    func getMaxVertexValue(vertices: [Vertex]) -> Int {
        
        var value = 0
        
        for vertex in vertices {
            if Int(vertex.value)! > Int(value) {
                value = Int(vertex.value)!
            }
        }
        
        return value
    }
    
    func hasVertex(vertices: [Vertex], vertex: Vertex) -> Bool {
        
        var has = false
        
        for v in vertices {
            if v.value == vertex.value {
                has = true
                break
            }
        }
        
        return has
    }
    
    func hasEdges(edges: [Edge], edge: Edge) -> Bool {
        
        var has = false
        
        for e in edges {
            if (e.vertex1.value == edge.vertex1.value && e.vertex2.value == edge.vertex2.value) || (e.vertex2.value == edge.vertex1.value && e.vertex1.value == edge.vertex2.value) {
                has = true
                break
            }
        }
        
        return has
    }
}
