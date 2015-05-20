//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

let X_OFFSET: CGFloat = -12.0
let Y_OFFSET: CGFloat = -10.0

class ViewController: UIViewController, HexagonViewDelegate {
    
    var cells: [HexagonView] = []
    var timer: NSTimer! = nil
    var grid: HexagonGrid! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createGrid()
//        timer = createTimer()
        let button: UIButton = UIButton.buttonWithType(.Custom) as! UIButton
        button.addTarget(self, action: Selector("pause:"), forControlEvents: .TouchUpInside)
		button.frame = CGRectMake(10, 10, 30, 30)
		button.setImage(UIImage(named: "button_play"), forState: .Normal)

        self.view.addSubview(button)
    }
    
    func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: Selector("tick:"), userInfo: nil, repeats: false)
    }
    
    func createGrid() {
        let cellHeight: CGFloat = 25
        let sideLength = cellHeight/2
        let cellWidth = CGFloat(sqrt(3.0)) * sideLength
        
        HexagonView.updateEdgePath(cellWidth, height: cellHeight, lineWidth: 2.0)
      
      
        grid = HexagonGrid(rows: 47, columns: 41)
//            grid = HexagonGrid(rows: 0, columns: 0)
        
        for hex in grid {
            let row = hex.location.row
            let column = hex.location.column
            let x = X_OFFSET + (column & 1 == 0 ? (cellWidth * CGFloat(row)) : (cellWidth * CGFloat(row)) + (cellWidth * 0.5))
            let y = Y_OFFSET + ((cellHeight - sideLength/2) * CGFloat(column))
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
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//        println("BACK")
        self.grid = nextGrid(self.grid)
        dispatch_async(dispatch_get_main_queue()) {
//          println("MAIN")
          for cell in self.cells {
            if let hexagon = self.grid.hexagon(atLocation: cell.coordinate) {
              cell.alive = hexagon.active
              cell.setNeedsDisplay()
            }
          }
          
          self.timer = self.createTimer()
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
    
    func pause(button: UIButton) {

        if let t = timer {
            t.invalidate()
            timer = nil
			button.setImage(UIImage(named: "button_play"), forState: .Normal)
        } else {
            timer = createTimer()
			button.setImage(UIImage(named: "button_stop"), forState: .Normal)
        }
    }
    
    deinit {
        timer.invalidate()
        timer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func prefersStatusBarHidden() -> Bool {
      return true;
    }
  
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
      return UIInterfaceOrientation.Portrait
    }
  
}

