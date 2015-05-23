//
//  ViewController.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit
   
// queue enforcing serial grid creation
let gridQueue = dispatch_queue_create("grid_queue", DISPATCH_QUEUE_SERIAL)

class ViewController: UIViewController, HexagonViewDelegate {
    var numberOfRows = 50
    var numberOfColumns: Int!
    var cells: [HexagonView] = []
    var timer: NSTimer!
    var grid: HexagonGrid!
    var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGrid()
        
        button = UIButton.buttonWithType(.Custom) as! UIButton
        button.addTarget(self, action: Selector("toggle:"), forControlEvents: .TouchUpInside)
		button.frame = CGRectMake(10, 10, 30, 30)
		button.setImage(UIImage(named: "button_play"), forState: .Normal)
        self.view.addSubview(button)
    }
    
    func createGrid() {
        let cellHeight: CGFloat = (view.bounds.height / (CGFloat(numberOfRows-1)) * 1.5)
        let sideLength = cellHeight/2
        let cellWidth = CGFloat(sqrt(3.0)) * sideLength
        let cellSize = CGSize(width: cellWidth, height: cellHeight)
        HexagonView.updateEdgePath(cellSize, lineWidth: 3)

        numberOfColumns = Int(ceil(view.bounds.width / cellWidth))
        
        dispatch_sync(gridQueue) {
            self.grid = HexagonGrid(rows: self.numberOfRows, columns: self.numberOfColumns, initialGridType: .Random)
        }
        
        let xOffset: CGFloat = -cellWidth/2
        let yOffset = -(cellHeight/4 + sideLength)
        
        for hexagon in grid {
            let row = hexagon.location.row
            let column = hexagon.location.column
            let x = xOffset + (row & 1 == 0 ? (cellWidth * CGFloat(column)) : (cellWidth * CGFloat(column)) + (cellWidth * 0.5))
            let y = yOffset + ((cellHeight - sideLength/2) * CGFloat(row))
            let frame = CGRect(x: x, y: y, width: cellWidth, height: cellHeight)
            let cell = HexagonView(frame: frame)
            cell.coordinate = hexagon.location
            cell.alive = hexagon.active
            cell.fillPath = cell.alive ? HexagonView.pathPrototype : nil
            cell.hexagonViewDelegate = self
            cells.append(cell)
            view.addSubview(cell)
        }
    }
    
    func updateGrid() {
        dispatch_async(gridQueue) {
            let grid = nextGrid(self.grid)
            self.grid = grid
            dispatch_async(dispatch_get_main_queue()) {
                self.drawGrid(grid)
            }
        }
    }
    
    func drawGrid(grid: HexagonGrid) {
        assert(NSThread.isMainThread(), "Expect main thread")
        
        // split cells by needed action. filter unchanged cells
        var cellsToActivate: [HexagonView] = []
        var cellsToDeactivate: [HexagonView] = []
        
        for cell in cells {
            if let hexagon = grid.hexagon(atLocation: cell.coordinate) {
                switch (cell.alive, hexagon.active) {
                case (false, true):
                    cellsToActivate.append(cell)
                case (true, false):
                    cellsToDeactivate.append(cell)
                default:()
                }
                
                cell.alive = hexagon.active
            }
        }
        
        // animate changes
        if cellsToActivate.count > 0 {
            let config = AnimationConfiguration(startValue: 0, endValue: 1, duration: 0.4)
            Animator.addAnimationForViews(cellsToActivate, configuration: config)
        }
        if cellsToDeactivate.count > 0 {
            let config = AnimationConfiguration(startValue: 1, endValue: 0, duration: 0.2)
            Animator.addAnimationForViews(cellsToDeactivate, configuration: config)
        }
    }

    
    // Timer
    func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
    }
    
    func tick(timer: NSTimer) {
        updateGrid()
    }
    
    // Button
    func toggle(button: UIButton) {
        if timer == nil {
            start()
        } else {
            stop()
        }
    }
    
    func start() {
        timer?.invalidate()
        timer = createTimer()
        timer.fire()
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
}

// HexagonView Delegate
extension ViewController: HexagonViewDelegate {
    func userDidUpateCell(cell: HexagonView) {
        dispatch_async(gridQueue) {
            let grid = self.grid.setActive(cell.alive, atLocation: cell.coordinate)
            self.grid = grid
            
            dispatch_async(dispatch_get_main_queue()){
                let alive = cell.alive
                let start: CGFloat = alive ? 0 : 1
                let end: CGFloat = alive ? 1 : 0
                let duration: CFTimeInterval = alive ? 0.2 : 0.1
                let config = AnimationConfiguration(startValue: start, endValue: end, duration: duration)
                Animator.addAnimationForViews([cell], configuration: config)
            }
        }
    }
}

// Shake
extension ViewController {
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

