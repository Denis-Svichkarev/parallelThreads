//
//  Extensions.swift
//  AlgoGraph
//
//  Created by Denis Svichkarev on 18/02/2017.
//  Copyright © 2017 Denis Svichkarev. All rights reserved.
//

import Foundation

extension String {
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
}
