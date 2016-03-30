//
//  Ruls.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import Foundation

struct Rules {
    let environment: [Int]
    let fertility: [Int]
    
    static func defaultRules() -> Rules {
//        return Rules(environment: [3,5], fertility: [2])
        return Rules(environment: [3], fertility: [2,4,5])
    }
    
    func perform(hexagon: Hexagon, numberOfActiveNeighbors: Int) -> Hexagon {
        if fertility.contains(numberOfActiveNeighbors) && !hexagon.active {
            return hexagon.setActive(true)
        } else if environment.contains(numberOfActiveNeighbors) {
            return hexagon
        }
        return hexagon.setActive(false)
    }
    
}