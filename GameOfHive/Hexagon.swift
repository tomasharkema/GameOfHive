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

extension Coordinate: Equatable {
    
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

extension Hexagon: Printable {
    public var description: String {
        return active ? "+" : "-"
    }
}


func above(location: Coordinate) -> (Coordinate,Coordinate) {
    return (Coordinate(row: location.row - 1, column: location.column),
    Coordinate(row: location.row - 1, column: location.column + 1))
}

func sameRow(location: Coordinate) -> (Coordinate,Coordinate) {
    return (Coordinate(row: location.row, column: location.column - 1),
        Coordinate(row: location.row, column: location.column + 1))
}

func below(location: Coordinate) -> (Coordinate,Coordinate) {
    return (Coordinate(row: location.row + 1, column: location.column),
        Coordinate(row: location.row + 1, column: location.column + 1))
}

func appendTuple(var array: [Coordinate], tuple:(Coordinate,Coordinate)) -> [Coordinate] {
    array.append(tuple.0)
    array.append(tuple.1)
    return array
}

public func neighboringLocations(hex: Coordinate) -> [Coordinate] {
    var result: [Coordinate] = []
    result = appendTuple(result, above(hex))
    result = appendTuple(result, sameRow(hex))
    result = appendTuple(result, below(hex))
    return result
}