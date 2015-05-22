//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HexagonViewDelegate {
    var numberOfRows = 15
    var numberOfColumns: Int!
    var cells: [HexagonView] = []
    var timer: NSTimer!
    var grid: HexagonGrid!
    var button: UIButton!
    var cellSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGrid()
        button = UIButton.buttonWithType(.Custom) as! UIButton
        button.addTarget(self, action: Selector("toggle:"), forControlEvents: .TouchUpInside)
		button.frame = CGRectMake(10, 10, 30, 30)
		button.setImage(UIImage(named: "button_play"), forState: .Normal)

        self.view.addSubview(button)
    }
    
    func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
    }
    
    func createGrid() {
        var cellHeight: CGFloat = (view.bounds.height / (CGFloat(numberOfRows-1)) * 1.5)
        let sideLength = cellHeight/2
        let cellWidth = CGFloat(sqrt(3.0)) * sideLength
        
        cellSize = CGSize(width: cellWidth, height: cellHeight)
        HexagonView.updateEdgePath(cellSize, lineWidth: 3)

        numberOfColumns = Int(ceil(view.bounds.width / cellWidth))
        let xOffset: CGFloat = -cellWidth/2
        let yOffset = -(cellHeight/4 + sideLength)
        
        HexagonView.updateEdgePath(cellWidth, height: cellHeight, lineWidth: 2.0)
      
        grid = HexagonGrid(rows: numberOfRows, columns: numberOfColumns, initialGridType: .Random)
        
        for hex in grid {
            let row = hex.location.row
            let column = hex.location.column
            let x = xOffset + (row & 1 == 0 ? (cellWidth * CGFloat(column)) : (cellWidth * CGFloat(column)) + (cellWidth * 0.5))
            let y = yOffset + ((cellHeight - sideLength/2) * CGFloat(row))
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
        self.grid = nextGrid(self.grid)
        dispatch_async(dispatch_get_main_queue()) {
          for cell in self.cells {
            if let hexagon = self.grid.hexagon(atLocation: cell.coordinate) {
              cell.alive = hexagon.active
              cell.setNeedsDisplay()
            }
          }
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
    
    func toggle(button: UIButton) {
        if timer == nil {
            start()
        } else {
            stop()
        }
    }
    
    deinit {
        stop()
    }
    
    func start() {
        timer?.invalidate()
        timer = createTimer()
        button.setImage(UIImage(named: "button_stop"), forState: .Normal)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        button.setImage(UIImage(named: "button_play"), forState: .Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    override func prefersStatusBarHidden() -> Bool {
      return true;
    }
  
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
      return .Portrait
    }
  
    /// pragma mark: Shake it baby
  
    override func canBecomeFirstResponder() -> Bool {
      return true
    }
  
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
    if motion == .MotionShake {
      grid = emptyGrid(numberOfRows,numberOfColumns)
      updateGrid()
      stop()
    }
  }
  
}

