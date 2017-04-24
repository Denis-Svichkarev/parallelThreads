//
//  ConsoleHelpers.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 17/02/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

/**
    Get user input string from console.
 */
func input() -> String {
    let keyboard = FileHandle.standardInput
    let inputData = keyboard.availableData
    
    return NSString(data: inputData, encoding: String.Encoding.utf8.rawValue) as! String
}

/**
    Get string from file using /Documents directory.
 */
func getStringFromFilePath(_ filePath: String) -> String? {
    
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        do {
            let path = dir.appendingPathComponent(filePath)
            let text = try String(contentsOf: path, encoding: String.Encoding.utf8)
            return text
        } catch {
            print("Can't open file")
            return nil
        }
    } else {
        print("Can't open default directory")
        return nil
    }
}

/**
    Create file with text or replace with new one to /Documents directory.
 */
func writeToFileString(_ filename: String, text: String) {
    
    if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        
        let path = dir.appendingPathComponent(filename)
        
        do {
            try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
        }
        catch {
            print("Can't write file to default directory")
        }
    }
}
