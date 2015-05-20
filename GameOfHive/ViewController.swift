//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height: CGFloat = 50
        let s = height/2
        let width = CGFloat(sqrt(3.0)) * s
      
      
        let hexagonGrid = HexagonGrid(rows: 50, columns: 50)
      
        for row in 0..<hexagonGrid.rows {
          for column in 0..<hexagonGrid.columns {
            
            let x = column & 1 == 0 ? (width * CGFloat(row)) : (width * CGFloat(row)) + (width * 0.5)
            let y = (height - s/2) * CGFloat(column)
            
            let hexView = HexagonView(frame: CGRect(x: x, y: y, width: width, height: height))
            if let hex = hexagonGrid.hexagon(atLocation:Coordinate(row: row, column: column)) {
                hexView.alive = hex.active
            }
            view.addSubview(hexView)
          }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

