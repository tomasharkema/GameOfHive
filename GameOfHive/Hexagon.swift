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
    return "\(row) : \(column)"
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
    return [Coordinate(row: location.row - 1, column: location.column)
        ,Coordinate(row: location.row - 1, column: location.column + 1)
        ,Coordinate(row: location.row, column: location.column - 1)
        ,Coordinate(row: location.row, column: location.column + 1)
        ,Coordinate(row: location.row + 1, column: location.column)
        ,Coordinate(row: location.row + 1, column: location.column + 1)
    ]
}