//
//  GridTests.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
import XCTest
@testable import GameOfHive

class GridTests: XCTestCase {
    func testGridLocation() {
        let grid = HexagonGrid(rows: 10, columns: 10, initialGridType: .Random)
        let hex: Hexagon! = grid.hexagon(atLocation: Coordinate(row: 4, column: 5))
        XCTAssert(hex != nil, "Hexagon should not be nil")
        XCTAssertEqual(hex.location,Coordinate(row: 4, column: 5))
    }
    
    func testPerformRules() {
        let rules = Rules.defaultRules
        var grid = HexagonGrid(rows: 5, columns: 5, initialGridType: .Empty)
        grid = grid.setActive(true, atLocation: Coordinate(row: 1, column: 2))
        grid = grid.setActive(true, atLocation: Coordinate(row: 3, column: 2))
        grid = rules.perform(grid)
        let hex1 = grid.hexagon(atLocation: Coordinate(row: 2, column: 2))
        let hex2 = grid.hexagon(atLocation: Coordinate(row: 2, column: 3))
        XCTAssertTrue(hex1!.active, "Hex 1 should be active")
        XCTAssertTrue(hex2!.active, "Hex 2 should be active")

        grid = HexagonGrid(rows: 5, columns: 5, initialGridType: .Empty)
        grid = grid.setActive(true, atLocation: Coordinate(row: 2, column: 3))
        grid = grid.setActive(true, atLocation: Coordinate(row: 4, column: 3))
        grid = rules.perform(grid)
        let hex3 = grid.hexagon(atLocation: Coordinate(row: 3, column: 2))
        let hex4 = grid.hexagon(atLocation: Coordinate(row: 3, column: 3))
        XCTAssertTrue(hex3!.active, "Hex 3 should be active")
        XCTAssertTrue(hex4!.active, "Hex 4 should be active")

    }
}
