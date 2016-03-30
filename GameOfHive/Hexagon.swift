//
//  Hexagon.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import Foundation

public struct Coordinate {
    let row: Int
    let column: Int
    public init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

extension Coordinate: CustomStringConvertible, Equatable {
  public var description: String {
    return "(\(row),\(column))"
  }
}

public func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

public struct Hexagon {
    public let active: Bool
    public let location: Coordinate
    public init(location: Coordinate, active: Bool = false) {
        self.location = location
        self.active = active
    }

    public init(row: Int, column: Int, active: Bool = false) {
        self.init(location: Coordinate(row: row, column: column),active: active)
    }
    
    public func setActive(active: Bool) -> Hexagon {
        return Hexagon(row: location.row, column: location.column, active: active)
    }
}

extension Hexagon: CustomStringConvertible {
    public var description: String {
        return active ? "+" : "-"
    }
}


public func neighboringLocations(location: Coordinate) -> [Coordinate] {
    let evenRow = location.row & 1 == 0
    let baseAdjustment = evenRow ? -1 : 0
    let leftColumn = location.column + baseAdjustment
    let rightColumn = leftColumn + 1
    let previousRow = location.row - 1
    let nextRow = location.row + 1
    
    return [Coordinate(row: previousRow, column: leftColumn)
        ,Coordinate(row: previousRow, column: rightColumn)
        ,Coordinate(row: location.row, column: location.column - 1)
        ,Coordinate(row: location.row, column: location.column + 1)
        ,Coordinate(row: nextRow, column: leftColumn)
        ,Coordinate(row: nextRow, column: rightColumn)
    ]
}