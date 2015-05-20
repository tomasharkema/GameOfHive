//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HexagonViewDelegate {
    
    var cells: [HexagonView] = []
    var timer: NSTimer! = nil
    var grid: HexagonGrid! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGrid()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func createGrid() {
        let cellHeight: CGFloat = 25
        let sideLength = cellHeight/2
        let cellWidth = CGFloat(sqrt(3.0)) * sideLength
        
        grid = HexagonGrid(rows: 50, columns: 50)
        
        for hex in grid {
            let row = hex.location.row
            let column = hex.location.column
            let x = column & 1 == 0 ? (cellWidth * CGFloat(row)) : (cellWidth * CGFloat(row)) + (cellWidth * 0.5)
            let y = (cellHeight - sideLength/2) * CGFloat(column)
            let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
            let cell = HexagonView(frame: frame)
            cell.coordinate = hex.location
            cell.alive = hex.active
            cell.hexagonViewDelegate = self
            cells.append(cell)
            view.addSubview(cell)
        }
    }
    
    func updateGrid() {
        grid = nextGrid(grid)
        for cell in cells {
            if let hexagon = grid.hexagon(atLocation: cell.coordinate) {
                cell.alive = hexagon.active
                cell.setNeedsDisplay()
            }
        }
    }
    
  
    func cellWithCoordinate(coordinate: Coordinate, frame: CGRect) -> HexagonView {
        let optionalCell = cells.filter { cell in
            cell.coordinate == coordinate
            }.first
        
        if let cell = optionalCell {
            cell.setNeedsDisplay()
            return cell
        }
        
        let cell = HexagonView(frame: frame)
        cells.append(cell)
        view.addSubview(cell)
        return cell
    }
  
    func userDidUpateCellAtCoordinate(coordinate: Coordinate, alive:Bool) {
        grid = grid.setActive(alive, atLocation: coordinate)
    }
  
    func tick(timer: NSTimer) {
        updateGrid()
    }
    
    deinit {
        timer.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

