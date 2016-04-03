//
//  HexagonGrid.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
import Argo

typealias HexagonRow = [Int: Hexagon]

public enum GridType {
  case Empty
  case Random
}

public struct HexagonGrid {
    private var count = 0
    private let grid: [Int: HexagonRow]
    
    var rows: Int {
        return grid.count
    }
    
    var columns: Int {
        return grid[0]?.count ?? 0
    }
    
    private init(grid: [Int: HexagonRow]) {
        self.grid = grid
        self.count = grid.count
    }
    
    public init(rows: Int = 10, columns: Int = 10, initialGridType: GridType) {
        let grid = initialGrid(rows,columns: columns,gridType: initialGridType)
        self.init(grid: grid)
    }
    
    func wrap(value: Int, max: Int) -> Int {
        if value < 0 {
            return value + max
        }
        if max <= value {
            return value - max
        }
        return value
    }
    
    public func hexagon(atLocation location: Coordinate) -> Hexagon? {
        let wrappedRow = wrap(location.row, max: rows)
        let wrappedColumn = wrap(location.column, max: columns)
        let wrappedLocation = Coordinate(row: wrappedRow, column: wrappedColumn)
        return grid[wrappedLocation.row]?[wrappedLocation.column]
    }
    
    func activeNeigbors(cell: Hexagon) -> Int {
        let ns = neighboringLocations(cell.location).reduce(0) { (value, location: Coordinate) in
            if let hex = hexagon(atLocation: location) where hex.active {
                return value+1
            }
            return value
            
        }
        return ns
    }
    
    func update(hexagon: Hexagon, forRules rules: Rules) -> Hexagon {
        return rules.update(hexagon, numberOfActiveNeighbors: activeNeigbors(hexagon))
    }
    
    public func setActive(active: Bool, atLocation location: Coordinate) -> HexagonGrid
    {
        var newGrid = grid
        var row: HexagonRow! = newGrid[location.row]
        if row == nil {
            return self
        }
        let hex: Hexagon! = row[location.column]
        if hex == nil {
            return self
        }
        row[location.column] = hex.setActive(active)
        newGrid[location.row] = row
        return HexagonGrid(grid: newGrid)
    }
    
    func nextIteration(rules: Rules) -> HexagonGrid {
        var nextIteration: [Int:HexagonRow] = [:]
        grid.forEach{ (rowNumber,row) in
            var nextRow: HexagonRow = [:]
            row.forEach { (columnNumber,hex) in
                let nextHex = update(hex, forRules: rules)
                nextRow[columnNumber] = nextHex
            }
            nextIteration[rowNumber] = nextRow
        }
        return HexagonGrid(grid: nextIteration)
        
    }
}

extension HexagonGrid: CustomStringConvertible {
    public var description: String {
        return grid.reduce("") { (prev, el) in
            let (_, row) = el
            return prev + row.reduce("") { (prev, el) in
                let (_, hex) = el
                return prev + hex.description
            }
        }
    }
}

extension HexagonGrid: SequenceType {
    public func generate() -> AnyGenerator<Hexagon> {
        var rowGenerator = self.grid.generate()
        var columnGenerator = rowGenerator.next()?.1.generate()
        return AnyGenerator {
            if let column = columnGenerator?.next()
            {
                return column.1
            }
            columnGenerator = rowGenerator.next()?.1.generate()
            return columnGenerator?.next()?.1
        }
    }
}

extension HexagonGrid: Encodable {
    public func encode() -> JSON {
        var data: [JSON] = []
        for rowIndex in 0..<rows {
            var rowString: String = ""
            for columnIndex in 0..<columns {
                if let hex = self.grid[rowIndex]?[columnIndex] {
                    rowString += hex.active ? "1" : "0"
                } else {
                    assertionFailure("Error encoding grid")
                    rowString += "x"
                }
            }
            data.append(.String(rowString))
        }
        let size: JSON = ["rows":rows,"columns":columns]
        let grid: JSON = ["data":data,"size":size]
        return ["grid":grid]
    }
}

extension HexagonGrid: Decodable {
    static var curriedInit: Int -> Int -> GridType -> HexagonGrid = { rows in
        return { columns in
            return { type in
                return HexagonGrid(rows: rows, columns: columns, initialGridType: type)
            }
        }
    }
    
    typealias RowData = String
    
    public static func decode(json: JSON) -> Decoded<HexagonGrid> {
        let decodedRows: Decoded<[RowData]> = json <|| ["grid","data"]
        let decodedGrid: Decoded<HexagonGrid> = curriedInit <^> json <| ["grid","size","rows"]
                                                     <*> json <| ["grid","size","columns"]
                                                     <*> pure(.Empty)
        return decodedGrid.map { grid in
            var newGrid = grid
            decodedRows.map { rows in
                rows.enumerate().forEach { (rowIndex,row) in
                    row.characters.enumerate().forEach { (columnIndex,character) in
                        let active = String(character) == "1"
                        newGrid = newGrid.setActive(active, atLocation: Coordinate(row: rowIndex, column: columnIndex))
                    }
                }
            }
            return newGrid
        }
    }
}

//MARK: Loading and saving
extension HexagonGrid {
    func save(filename: String = "grid.json") throws {
        let file = documentsDirectory.stringByAppendingPathComponent(filename)
        try self.encode().toJSONString.writeToFile(file, atomically: true, encoding: NSUTF8StringEncoding)
    }
    
    static func load(filename: String = "grid.json") -> HexagonGrid? {
        let file = documentsDirectory.stringByAppendingPathComponent(filename)
        guard let data = NSData(contentsOfFile: file), object = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) else {
            return nil
        }
        let decodedGrid: Decoded<HexagonGrid> = Argo.decode(object)
        return decodedGrid.value
    }
}



func initialGrid(rows: Int, columns: Int, gridType: GridType) -> [Int: HexagonRow] {
    var grid: [Int:HexagonRow] = [:]
    for r in 0..<rows {
        var row: HexagonRow = [:]
        for c in 0..<columns {
            let active = gridType == .Empty ? false : arc4random_uniform(10) == 1
            row[c] = Hexagon(row: r, column: c, active: active)
        }
        grid[r] = row
    }
    return grid
}



func gridFromViewDimensions(gridSize: CGSize, cellSize: CGSize, gridType: GridType = .Empty) -> HexagonGrid {
    let colums = Int(ceil(gridSize.width / cellSize.width)) + 1
    let rows = Int(ceil(gridSize.height / ((3 * cellSize.height) / 4))) + 1
    
    return HexagonGrid(rows: rows, columns: colums, initialGridType: gridType)
}