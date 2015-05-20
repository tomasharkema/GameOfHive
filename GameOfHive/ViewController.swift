//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var cells: [HexagonView] = []
    var timer: NSTimer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let height: CGFloat = 25
        let s = height/2
        let width = CGFloat(sqrt(3.0)) * s
      
        let grid = HexagonGrid(rows: 50, columns: 50)
        updateGrid(grid, cellWidth: width, cellHeight: height, sideLength: s)
      
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    func updateGrid(grid: HexagonGrid, cellWidth: CGFloat, cellHeight: CGFloat, sideLength: CGFloat) {
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                
                let x = column & 1 == 0 ? (cellWidth * CGFloat(row)) : (cellWidth * CGFloat(row)) + (cellWidth * 0.5)
                let y = (cellHeight - sideLength/2) * CGFloat(column)
                
                let hexView = HexagonView(frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight))
                if let hex = grid.hexagon(atLocation:Coordinate(row: row, column: column)) {
                    hexView.alive = hex.active
                }
                view.addSubview(hexView)
            }
        }
    }
    
    
    func tick(timer: NSTimer) {
        
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

