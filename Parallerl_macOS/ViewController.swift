//
//  ViewController.swift
//  Parallerl_macOS
//
//  Created by Denis Svichkarev on 24/04/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var taskTextView: NSTextView!
    @IBOutlet var consoleTextView: NSTextView!
    @IBOutlet var sourceGraphTextView: NSTextView!
    @IBOutlet weak var threadCountTextField: NSTextField!
    @IBOutlet weak var veticesCountTextField: NSTextField!
    
    var weightedGraph = WeightedGraph()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTextView.isEditable = false
        consoleTextView.isEditable = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - IB Actions
    
    @IBAction func onGenerateButtonPressed(_ sender: Any) {
        
        if let verticesCount = Int(veticesCountTextField.stringValue) {
            generateHugeSimpleGraph(vertices: verticesCount)
        }
    }

    @IBAction func onLoadButtonPressed(_ sender: Any) {
        
        if let verticesCount = Int(veticesCountTextField.stringValue) {
            weightedGraph = WeightedGraph()
            _ = weightedGraph.initWithFileName("parallel_tasks_vCount_\(verticesCount).txt")
            sourceGraphTextView.string = weightedGraph.printWeightedGraph()
        }
    }
    
    @IBAction func onCalculateButtonPressed(_ sender: NSButton) {
        
        if let count = Int(threadCountTextField.stringValue) {
            
            let threadsCount = count
            var i = 0
            
            let startDate = Date()
            
            weightedGraph.prima(theadsCount: threadsCount) { result in
                i += 1
                self.consoleTextView.string?.append(result.0)
                
                let edges = result.2
                
                //self.consoleTextView.string?.append("\n")
                
                for e in edges {
                    self.consoleTextView.string?.append(e)
                }
                
                self.consoleTextView.string?.append("\n")
                
                if i == threadsCount {
                    let interval = String(format: "%.5f", -startDate.timeIntervalSinceNow)
                    self.consoleTextView.string?.append("Time: " + interval + "\n\n")
                }
            }
            
            print("\n")
        }
    }
    
    // MARK: - Graph generation
    
    func generateHugeSimpleGraph(vertices: Int) {
        
        var resultString = ""
        
        resultString.append("\(vertices)\n")
        
        for i in 1...vertices {
            
            let endVertex = Int(arc4random_uniform(UInt32(vertices)) + 1)
            if endVertex == i {
                continue
            }
            
            let weight = Int(arc4random_uniform(100) + 1)
            
            resultString.append("\(i) \(endVertex) \(weight)\n")
        }
        
        for i in 1...vertices {
            for j in 1...vertices {
                
                if i == j {
                    continue
                }
                
                let weight = Int(arc4random_uniform(100) + 1)
                resultString.append("\(i) \(j) \(weight)\n")
            }
        }
        
        writeToFileString("parallel_tasks_vCount_\(vertices).txt" , text: resultString)
    }
}

