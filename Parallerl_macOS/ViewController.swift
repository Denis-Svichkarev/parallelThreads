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

    
    @IBAction func onCalculateButtonPressed(_ sender: NSButton) {
        
        let weightedGraph = WeightedGraph()
        _ = weightedGraph.initWithFileName("generated_graph_v21_4.txt")
        
        sourceGraphTextView.string = weightedGraph.printWeightedGraph()
        
        let threadsCount = 2
        var i = 0
        
        let startDate = Date()
            
        weightedGraph.prima(theadsCount: 2) { result in
            i += 1
            
            if i == threadsCount {
                let interval = String(format: "%.5f", -startDate.timeIntervalSinceNow)
                self.consoleTextView.string?.append("Time: " + interval + "\n")
            }
        }
        
        print("")
    }
}

