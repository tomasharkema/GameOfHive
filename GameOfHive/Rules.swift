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
    
    static let defaultRules: Rules = Rules(environment: [3], fertility: [2,4,5])
    static let otherRules: Rules = Rules(environment: [3,5], fertility: [2])

    static func randomRules() -> Rules {
        let environment = randomArray()
        let fertility = randomArray()
        return Rules(environment: environment, fertility: fertility)
    }
    
    private static func randomArray(from: Int = 1, to: Int = 6) -> [Int] {
        var result: [Int] = []
        for value in from...to {
            if arc4random_uniform(2) == 1 {
                result.append(value)
            }
        }
        return result
    }
    
    
    func update(hexagon: Hexagon, numberOfActiveNeighbors: Int) -> Hexagon {
        if fertility.contains(numberOfActiveNeighbors) && !hexagon.active {
            return hexagon.setActive(true)
        } else if environment.contains(numberOfActiveNeighbors) {
            return hexagon
        }
        return hexagon.setActive(false)
    }
    
    func perform(grid: HexagonGrid) -> HexagonGrid {
        return grid.nextIteration(self)
    }
    
}

extension Rules: CustomStringConvertible {
    var description: String {
        let envString = (environment.map{$0.description}).joinWithSeparator(",")
        let fertString = (fertility.map{$0.description}).joinWithSeparator(",")
        return "\(envString)/\(fertString)"
    }
}