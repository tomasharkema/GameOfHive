//
//  GridTests.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
import XCTest
import GameOfHive

class GridTests: XCTestCase {
    func testGridLocation() {
        let grid = HexagonGrid(rows: 10, columns: 10)
        let hex: Hexagon! = grid.hexagon(atLocation: Coordinate(row: 4, column: 5))
        XCTAssert(hex != nil, "Hexagon should not be nil")
        XCTAssertEqual(hex.location,Coordinate(row: 4, column: 5))
    }
}
