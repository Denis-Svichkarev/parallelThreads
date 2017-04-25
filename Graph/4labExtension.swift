//
//  4labExtension.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 10/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

extension WeightedGraph {

    // MARK: - 1 Task
    
    func borvka() {
        
        F = Graph()
        F?.initAsSimpleGraph(graph: self)
        F?.adjList = adjList
        
        for e in weightedEdges {
            F?.edges.append(Edge(vertex1: e.vertex1, vertex2: e.vertex2, degree: e.weight))
        }

        let components = F?.getLinkedComponents()
        var component = components?[0]
        
        for c in components! {
            if c.count > (component?.count)! {
                component = c
            }
        }
        
        let newWeightedGraph = generateSimpleGraph(component: component!)
        
        adjWList = newWeightedGraph.adjWList
        vertices = newWeightedGraph.vertices
        markers = newWeightedGraph.markers
        adjList = newWeightedGraph.adjList
        weightedEdges = newWeightedGraph.weightedEdges
        
        F = Graph()
        F?.initAsSimpleGraph(graph: self)
        F?.adjList = adjList
        
        for i in 0..<(F?.adjList)!.count {
            F?.adjList[i].removeAll()
        }
        
        var count = F!.countAndLabel()
        
        while count > 1 {
            labels = F!.labels
            addAllSafeEdges(count: count)
            count = F!.countAndLabel()
            print("count: \(count)\n")
        }
        
        if let F = F {
            
            for i in 0..<F.vertices.count {
                print("\(i + 1):", terminator: " ")
                
                for x in adjWList[i] {
                    print("(\(x.0), \(x.1))", terminator: " ")
                }
                
                print("")
            }
        }
    }
    
    func addAllSafeEdges(count: Int) {
        
        var S = [(Int, Int, Int)]()
        
        for _ in 0..<count {
            S.append((0, 0, 1000))
        }
        
        for u in 1...vertices.count {
            for v in adjWList[u - 1] {
                if labels[u - 1] != labels[v.0 - 1] {
                    if v.1 < S[labels[u - 1] - 1].2 {
                        S[labels[u - 1] - 1] = (u, v.0, v.1)
                    }
                    if v.1 < S[labels[v.0 - 1] - 1].2 {
                        S[labels[v.0 - 1] - 1] = (u, v.0, v.1)
                    }
                }
            }
        }
        
        for i in 0..<count {
            if S[i].2 != 1000 {
                F?.addEdge(v: S[i].0, w: S[i].1)
            }
        }
        
        if let F = F {
            
            for i in 0..<F.vertices.count {
                print("\(i + 1):", terminator: " ")
                
                for x in F.adjList[i] {
                    print("\(x)", terminator: " ")
                }
                
                print("")
            }
            
            print("")
        }
    }
    
    func generateSimpleGraph(component: [String]) -> WeightedGraph {
        
        var newEdges = [WeightedEdge]()
        
        for edge in weightedEdges {
            
            var connected = false
            
            for v in component {
                if v == edge.vertex1.value {
                    connected = true
                    break
                }
            }
            
            if connected {
                newEdges.append(edge)
            }
        }
        
        let orientedGraphString = generateInputTextStringWithWeightedEdges(edges: newEdges)
        writeToFileString("generated_graph_v21_4.txt", text: orientedGraphString)
        
        let newGraph = WeightedGraph()
        _ = newGraph.initWithFileName("generated_graph_v21_4.txt")
        
        return newGraph
    }
    
    // MARK: - 2 Task
    
    func prima(theadsCount: Int, completion: @escaping (_ result: String, _ threadIndex: Int, _ edges: [String]) -> Void) {
        
        markedVertices = [Vertex]()
        markedEdges = [WeightedEdge]()
        
        if self.weightedEdges.count < theadsCount {
            let edges = [String]()
            completion("Error", 0, edges)
            return
        }
        
        for i in 0..<theadsCount {
            
            let concurrentQueue = DispatchQueue(label: "queue\(i)", attributes: .concurrent)
            concurrentQueue.async {
                
                self.runNewPrima(weightedEdge: self.weightedEdges[i], threadIndex: i + 1, theadsCount:theadsCount, completion: { edges in
                    
                    DispatchQueue.main.async {
                        completion("\(i + 1) done", i + 1, edges)
                    }
                })
            }
        }
    }
    
    func runNewPrima(weightedEdge: WeightedEdge, threadIndex: Int, theadsCount: Int, completion: @escaping (_ edges: [String]) -> Void) {
        
        var markedVerticesInThread = [Vertex]()
        markedVerticesInThread.append(weightedEdge.vertex1)
        
        var minEdge: WeightedEdge?
        var markedEdgesInThread = [String]()
        
        load(theadsCount: theadsCount)
        
        while (true) {
            
            var minWeight = 10000
            
            // 1. Find min edge
            
            var stableArray = [WeightedEdge]()
            
            let lock = NSLock()
            
            synchronized(lockable: lock) {
                stableArray = NSArray(array: self.markedEdges, copyItems: true) as! [WeightedEdge]
            }
            
            for v in markedVerticesInThread {
                for e in self.weightedEdges {
                    
                    var existInMarked = false
                    
                    for e2 in stableArray {
                        if (e.vertex1.value == e2.vertex1.value && e.vertex2.value == e2.vertex2.value)
                            || (e.vertex2.value == e2.vertex1.value && e.vertex1.value == e2.vertex2.value) {
                            existInMarked = true ; break
                        }
                    }
                    
                    if existInMarked { continue }
                    
                    if e.vertex1.value == v.value {
                        if !self.hasVertex(vertices: markedVerticesInThread, vertex: e.vertex2) {
                            if e.weight < minWeight { minWeight = e.weight; minEdge = e }
                        }
                        
                    } else if e.vertex2.value == v.value {
                        if !self.hasVertex(vertices: markedVerticesInThread, vertex: e.vertex1) {
                            if e.weight < minWeight { minWeight = e.weight; minEdge = e }
                        }
                    }
                }
            }
            
            // 2. Add edge to tree
            
            if let minEdge = minEdge {
                
                markedEdges.append(minEdge)
                
                if !hasVertex(vertices: markedVerticesInThread, vertex: minEdge.vertex1) {
                    markedVerticesInThread.append(minEdge.vertex1)
                }
                
                if !hasVertex(vertices: markedVerticesInThread, vertex: minEdge.vertex2) {
                    markedVerticesInThread.append(minEdge.vertex2)
                }
                
                //print("Поток: \(threadIndex) Ребро: " + minEdge.vertex1.value + " - " + minEdge.vertex2.value)
                markedEdgesInThread.append("\nПоток: \(threadIndex) Ребро: " + minEdge.vertex1.value + " - " + minEdge.vertex2.value)
                
                if !self.hasVertex(vertices: self.markedVertices, vertex: minEdge.vertex1) {
                    self.markedVertices.append(minEdge.vertex1)
                }
                
                if !self.hasVertex(vertices: self.markedVertices, vertex: minEdge.vertex2) {
                    self.markedVertices.append(minEdge.vertex2)
                }
            }
            
            // 3. Check if all vertices were marked
            
            if markedVertices.count >= vertices.count {
                completion(markedEdgesInThread)
                break
            }
        }
    }
    
    func runPrima(weightedEdge: WeightedEdge, threadIndex: Int, completion: @escaping (_ edges: [String]) -> Void) {
        
        var markedVerticesInThread = [Vertex]()
        markedVerticesInThread.append(weightedEdge.vertex1)
        
        var minEdge: WeightedEdge?
        var markedEdgesInThread = [String]()
        
        while (true) {
            
            var minWeight = 10000
            
            //DispatchQueue.main.sync {
                
                for v in markedVerticesInThread {
                    for e in self.weightedEdges {
                        
                        var existInMarked = false
                        
                        for e2 in markedEdges {
                            if (e.vertex1.value == e2.vertex1.value && e.vertex2.value == e2.vertex2.value)
                                || (e.vertex2.value == e2.vertex1.value && e.vertex1.value == e2.vertex2.value) {
                                existInMarked = true
                                break
                            }
                        }
                        
                        if existInMarked {
                            continue
                        }
                        
                        if e.vertex1.value == v.value {
                            
                            if !self.hasVertex(vertices: markedVerticesInThread, vertex: e.vertex2) {
                                if e.weight < minWeight {
                                    minWeight = e.weight
                                    minEdge = e
                                }
                            }
                            
                        } else if e.vertex2.value == v.value {
                            
                            if !self.hasVertex(vertices: markedVerticesInThread, vertex: e.vertex1) {
                                if e.weight < minWeight {
                                    minWeight = e.weight
                                    minEdge = e
                                }
                            }
                        }
                    }
                }
            //}
            
            if let minEdge = minEdge {
                
                //DispatchQueue.main.sync {
                    markedEdges.append(minEdge)
                    
                    if !hasVertex(vertices: markedVerticesInThread, vertex: minEdge.vertex1) {
                        markedVerticesInThread.append(minEdge.vertex1)
                    }
                    
                    if !hasVertex(vertices: markedVerticesInThread, vertex: minEdge.vertex2) {
                        markedVerticesInThread.append(minEdge.vertex2)
                    }
                    
                    //print("Поток: \(threadIndex) Ребро: " + minEdge.vertex1.value + " - " + minEdge.vertex2.value)
                    markedEdgesInThread.append("Поток: \(threadIndex) Ребро: " + minEdge.vertex1.value + " - " + minEdge.vertex2.value + "\n")
                
                    if !self.hasVertex(vertices: self.markedVertices, vertex: minEdge.vertex1) {
                        self.markedVertices.append(minEdge.vertex1)
                    }
                    
                    if !self.hasVertex(vertices: self.markedVertices, vertex: minEdge.vertex2) {
                        self.markedVertices.append(minEdge.vertex2)
                    }
                //}
            }
    
            if markedVertices.count >= vertices.count {
                completion(markedEdgesInThread)
                break
            }
        }
    }
    
    func load(theadsCount: Int) {
        for _ in 0..<(100000 / theadsCount) {
            for i in 0..<100 {
                for j in 0..<100 {
                    let a = i * j
                }
            }
        }
    }
    
    // MARK: - 3 Task
    
    func kruskal() {
        
        kruskarEdges = [WeightedEdge]()
        
        weightedEdges.sort {
            $0.weight < $1.weight
        }

        while true {
        
            let edge = weightedEdges.first
            kruskarEdges.append(edge!)
    
            markers = Array<Bool>()
            
            for _ in adjWList {
                markers.append(false)
            }
            
            tempAdjWList = Array<Array<(Int, Int)>>()
            
            for _ in adjWList {
                tempAdjWList.append(Array())
            }
            
            for e in kruskarEdges {
                
                for w in 0..<adjWList.count {
                    for u in 0..<adjWList[w].count {
                        
                        if (adjWList[w][u].0 == Int((e.vertex1.value))! && w + 1 == Int((e.vertex2.value))!) ||
                            (adjWList[w][u].0 == Int((e.vertex2.value))! && w + 1 == Int((e.vertex1.value))!) {
                            
                            var exist = false
                            
                            for i in tempAdjWList[w] {
                                if i.0 == adjWList[w][u].0 {
                                    exist = true
                                    break
                                }
                            }
                            
                            if !exist {
                                tempAdjWList[w].append(adjWList[w][u])
                            }
                        }
                    }
                }
            }
            
            unmark()
            
            weightedEdges.remove(at: 0)
            
            for i in 0..<statuses.count {
                statuses[i] = .new
            }
            
            var k_vertices = [Vertex]()
            
            for _ in 0..<markers.count {
                k_vertices.append(Vertex(value: "", degree: 0, degreeIn: 0, degreeOut: 0, isHanging: false, isIsolated: false, isLooped: false, isSource: false, isSink: false, status: .new))
            }
            
            for e in kruskarEdges {
                if !hasVertex(vertices: k_vertices, vertex: e.vertex1) {
                    k_vertices.insert(e.vertex1, at: Int(e.vertex1.value)! - 1)
                    k_vertices.remove(at: Int(e.vertex1.value)!)
                }
                
                if !hasVertex(vertices: k_vertices, vertex: e.vertex2) {
                    k_vertices.insert(e.vertex2, at: Int(e.vertex2.value)! - 1)
                    k_vertices.remove(at: Int(e.vertex2.value)!)
                }
            }
            
            print((edge?.vertex1.value)! + " - " + (edge?.vertex2.value)!)
            
            var cycle = false
            
            for v in k_vertices {
                if v.value != "" {
                    
                    unmark()
                    
                    if isCyclicUtil(v: Int(v.value)! - 1, parent: -1) {
                        print("\nРебро: " + (edge?.vertex1.value)! + " - " + (edge?.vertex2.value)! + " вызвало цикл и было отброшено\n")
                        cycle = true
                        break
                    }
                }
            }
            
            if cycle {
                kruskarEdges.removeLast()
            }
            
            if weightedEdges.count == 0 {
                print("\nМинимальное остовное дерево построено.")
                break
            }
        }
    }
    
    func isCyclicUtil(v: Int, parent: Int) -> Bool {
        
        markers[v] = true
        
        for i in tempAdjWList[v] {
            if !markers[i.0 - 1] {
                if isCyclicUtil(v: i.0 - 1, parent: v) {
                    return true
                }
            } else if i.0 - 1 != parent {
                return true
            }
        }
        
        return false
    }
}

extension Graph {
    
    func initAsSimpleGraph(graph: Graph) {
        
        vertices = graph.vertices
        
        for _ in 0..<vertices.count { // resize markers array
            markers.append(false)
        }
        
        for _ in 0..<vertices.count { // resize adjacent list of vertices
            adjList.append(Array())
        }
        
        for _ in 0..<vertices.count { // resize labels
            labels.append(0)
        }
    }
    
    func countAndLabel() -> Int {
        var count = 0
        unmark()
        
        for v in 1...vertices.count {
            if !markers[v - 1] {
                count += 1
                labelComponent(v: v, count: count)
            }
        }
        
        return count
    }
    
    func labelComponent(v: Int, count: Int) {
        markers[v - 1] = true
        labels[v - 1] = count
        
        for w in adjList[v - 1] {
            if !markers[w - 1] {
                labelComponent(v: w, count: count)
            }
        }
    }
    
    func addEdge(v: Int, w: Int) {
        
        if v < 1 || v > vertices.count {
            return
        }
        
        if w < 1 || w > vertices.count {
            return
        }
        
        for x in adjList[v - 1] {
            if x == w {
                return
            }
        }
        
        adjList[v - 1].append(w)
        adjList[w - 1].append(v)
    }
    
    func generateInputTextStringWithWeightedEdges(edges: [WeightedEdge]) -> String {
        
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
        
        text.append("\(newVertices.count)\n")
        
        
        var verticesForRemove = [Vertex]()
        
        for v in vertices {
            var remove = true
            
            for e in edges {
                if e.vertex1.value == v.value || e.vertex2.value == v.value {
                    remove = false
                    break
                }
            }
            
            if remove {
                verticesForRemove.append(v)
            }
        }
        
        var newEdges = [WeightedEdge]()
        
        for i in 0..<edges.count {
            var edge = edges[i]
            
            var count1 = 0
            var count2 = 0
            
            for v in verticesForRemove {
            
                let n = Int(edge.vertex1.value)!
                
                if n > Int(v.value)! {
                    count1 += 1
                }
                
                let n2 = Int(edge.vertex2.value)!
                
                if n2 > Int(v.value)! {
                    count2 += 1
                }
            }
            
            edge.vertex1.value = "\(Int(edge.vertex1.value)! - count1)"
            edge.vertex2.value = "\(Int(edge.vertex2.value)! - count2)"
            
            newEdges.append(edge)
        }
        
        for edge in newEdges {
            text.append(edge.vertex1.value + " " + edge.vertex2.value + " \(edge.weight)" + "\n")
        }
        
        return text
    }
}
