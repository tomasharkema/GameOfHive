//
//  Argo.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import Foundation
import Argo

extension JSON {
    var toJSONString: Swift.String {
        switch self {
        case .Object(let o):
            var strings: [Swift.String] = []
            for (key,value) in o {
                strings.append("\"\(key)\":\(value.toJSONString)")
            }
            let joinedStrings = strings.joinWithSeparator(",")
            return "{\(joinedStrings)}"
        case .Array(let values):
            let joinedStrings = values.map({$0.toJSONString}).joinWithSeparator(",")
            return "[\(joinedStrings)]"
        case .String(let v): return "\"\(v)\""
        case .Number(let v): return "\(v)"
        case .Null: return "null"
        }
    }
}