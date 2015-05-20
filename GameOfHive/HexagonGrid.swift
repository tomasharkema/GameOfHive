//
//  HexagonGrid.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import Foundation

typealias HexagonRow = [Hexagon]

public enum GridType {
  case Empty
  case Random
}

public struct HexagonGrid {
    private let grid: [HexagonRow]
    private let rules: Rules = Rules.defaultRules()
    
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
    
    public init(rows: Int = 10, columns: Int = 10, initialGridType: GridType) {
        let grid = initialGrid(rows,columns,initialGridType)
        self.init(grid: grid)
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
        return rules.perform(cell, numberOfActiveNeighbors: activeNeigbors(cell))
    }
    
    func setActive(active: Bool, atLocation location: Coordinate) -> HexagonGrid
    {
        var newGrid = grid
        if newGrid.count < location.row {
            return self
        }
        var row = newGrid[location.row]
        if row.count < location.column {
            return self
        }
        row[location.column] = row[location.column].setActive(active)
        newGrid[location.row] = row
        return HexagonGrid(grid: newGrid)
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

extension HexagonGrid: SequenceType {
    public func generate() -> GeneratorOf<Hexagon> {
        var rowGenerator = self.grid.generate()
        var columnGenerator = rowGenerator.next()?.generate()
        return GeneratorOf<Hexagon> {
            if let column = columnGenerator?.next()
            {
                return column
            }
            columnGenerator = rowGenerator.next()?.generate()
            return columnGenerator?.next()
        }
    }
}

func initialGrid(rows: Int, columns: Int, gridType: GridType) -> [HexagonRow] {
    var grid: [HexagonRow] = []
    for r in 0...rows {
        var row: HexagonRow  = []
        for c in 0...columns {
            let active = gridType == .Empty ? false : arc4random_uniform(30) == 1
            row.append(Hexagon(row: r, column: c, active: active))
        }
        grid.append(row)
    }
    return grid
}


func nextGrid(grid: HexagonGrid) -> HexagonGrid {
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

func emptyGrid(grid: HexagonGrid) -> HexagonGrid {
  return HexagonGrid(rows: grid.rows, columns: grid.columns, initialGridType: .Empty)
}