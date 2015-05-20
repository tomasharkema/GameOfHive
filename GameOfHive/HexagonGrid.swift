//
//  HexagonGrid.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import Foundation

typealias HexagonRow = [Hexagon]

public struct HexagonGrid {
    private let grid: [HexagonRow]
    
    public var rows: Int {
        return grid.count
    }
    
    public var columns: Int {
        if rows == 0 {
            return 0
        }
        return grid[0].count
    }
    
    private init(grid: [HexagonRow]) {
        self.grid = grid
    }
    
    public init(rows: Int = 10, columns: Int = 10) {
        var initalGrid: [HexagonRow] = []
        for r in 0...rows {
            var row = initalGrid[r] ?? []
            for c in 0...columns {
                let active = arc4random_uniform(1) == 1
                row[c] = Hexagon(row: r, column: c, active: active)
            }
            initalGrid[r] = row
        }
        self.grid = initalGrid
    }
    
    public func hexagon(atLocation location: Coordinate) -> Hexagon? {
        if location.row < 0 || location.row >= self.grid.count {
            return nil
        }
        let row = self.grid[location.row]
        if location.column < 0 || location.column >= row.count {
            return nil
        }
        return row[location.column]
    }
    
    func neighbors(cell: Hexagon) -> [Hexagon] {
        let ns = neighboringLocations(cell.location)
        var cells: [Hexagon] = []
        for n in ns {
            if let hex = hexagon(atLocation:n) {
                cells.append(hex)
            }
        }
        return cells
    }
    
    func activeNeigbors(cell: Hexagon) -> Int {
        return neighbors(cell).filter({ $0.active }).count
    }
    
    public func nextIteration(cell: Hexagon) -> Hexagon {
        let isActive: Bool
        switch activeNeigbors(cell) {
        case 2:
            isActive = cell.active
        case 3:
            isActive = true
        default:
            isActive = false
        }
        return isActive ? cell.activate() : cell
    }
}

extension HexagonGrid: Printable {
    public var description: String {
        var output = ""
        for row in self.grid {
            for hex in row {
                output += hex.description
            }
            output += "\n"
        }
        return output
    }
}


func iterate(grid: HexagonGrid) -> HexagonGrid {
    var nextIteration: [HexagonRow] = []
    for row in grid.grid {
        var nextRow: HexagonRow = []
        for hex in row {
            let nextHex = grid.nextIteration(hex)
            nextRow.append(nextHex)
        }
        nextIteration.append(nextRow)
    }
    return HexagonGrid(grid: nextIteration)
}