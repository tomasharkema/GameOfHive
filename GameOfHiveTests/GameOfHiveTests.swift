//
//  GameOfHiveTests.swift
//  GameOfHiveTests
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
import XCTest
import GameOfHive

class GameOfHiveTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testHexagonCoordinate() {
        var hexagons: [Hexagon] = []
        for row in 0...10 {
            for column in 0...10 {
                let hex = Hexagon(row: row, column: column)
                hexagons.append(hex)
                
            }
        }
    }
    
    func testNeighbors() {
        var input = Coordinate(row: 1, column: 1)
        var coordinates = neighbors(input)
        XCTAssert(coordinates.count == 6, "has six values")
        XCTAssert(contains(coordinates,Coordinate(row: 0, column: 1)), "")
        XCTAssert(contains(coordinates,Coordinate(row: 0, column: 1)), "")
        XCTAssert(contains(coordinates,Coordinate(row: 1, column: 0)), "")
        XCTAssert(contains(coordinates,Coordinate(row: 1, column: 2)), "")
        XCTAssert(contains(coordinates,Coordinate(row: 2, column: 1)), "")
        XCTAssert(contains(coordinates,Coordinate(row: 2, column: 2)), "")
    }
}
