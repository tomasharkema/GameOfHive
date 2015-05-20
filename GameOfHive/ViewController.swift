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
      
      
        let hexagonGrid = HexagonGrid()
      
      
        for row in 0..<hexagonGrid.rows {
          for column in 0..<hexagonGrid.columns {
            let hexView = HexagonView(frame: CGRect(x: 25.0 * CGFloat(row), y: 25.0 * CGFloat(column), width: width, height: height))
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

