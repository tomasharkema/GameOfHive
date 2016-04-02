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

let cellSize = CGSize(width: 22, height: 25)
let sideLength = cellSize.height/2

class ViewController: UIViewController {
    var cells: [HexagonView] = []
    var timer: NSTimer!
    var grid: HexagonGrid!
    let rules = Rules.defaultRules
    var button: UIButton!
    var saveButton = UIButton(type: UIButtonType.RoundedRect)
    var loadButton = UIButton(type: UIButtonType.RoundedRect)
    var menuView: MenuView? = nil
    
    // MARK: UIViewController
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.LandscapeLeft,.LandscapeRight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGrid()
        
        button = UIButton(type: .Custom)
        button.addTarget(self, action: #selector(toggle(_:)), forControlEvents: .TouchUpInside)
		button.frame = CGRectMake(10, 10, 30, 30)
		button.setImage(UIImage(named: "button_play"), forState: .Normal)
        self.view.addSubview(button)
        
        saveButton.setTitle("save", forState: .Normal)
        loadButton.setTitle("load", forState: .Normal)
        self.view.addSubview(saveButton)
        self.view.addSubview(loadButton)
        saveButton.frame.size = CGSize(width: 50, height: 50)
        loadButton.frame.size = CGSize(width: 50, height: 50)
        saveButton.frame.origin = CGPoint(x: 10, y: button.frame.maxY)
        loadButton.frame.origin = CGPoint(x: 10, y: saveButton.frame.maxY)
        saveButton.addTarget(self, action: #selector(saveGrid), forControlEvents: .TouchUpInside)
        loadButton.addTarget(self, action: #selector(loadGrid), forControlEvents: .TouchUpInside)
        saveButton.setTitleColor(UIColor.darkAmberColor, forState: .Normal)
        loadButton.setTitleColor(UIColor.darkAmberColor, forState: .Normal)
        
    }
    
    var savePath: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return "\(documentsPath)/save.json"
    }
    
    func saveGrid() {
        do { try grid.save() } catch let error {
            print("Error saving grid",error)
        }
    }
    
    func loadGrid() {
        guard let g = HexagonGrid.load() else {
            return
        }
        grid = g
        drawGrid(grid)
    }
    
    
    // MARK: Grid
    func createGrid() {
        assert(timer == nil, "Expect not running")
        assert(grid == nil, "Expect grid does not exist")

        grid = gridFromViewDimensions(view.bounds.size, cellSize: cellSize, gridType: .Random)

        let xOffset = -cellSize.width/2
        let yOffset = -(cellSize.height/4 + sideLength)
        
        for hexagon in grid {
            let row = hexagon.location.row
            let column = hexagon.location.column
            let x = xOffset + (row & 1 == 0 ? (cellSize.width * CGFloat(column)) : (cellSize.width * CGFloat(column)) + (cellSize.width * 0.5))
            let y = yOffset + ((cellSize.height - sideLength/2) * CGFloat(row))
            let frame = CGRect(x: x, y: y, width: cellSize.width, height: cellSize.height)
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
            let grid = self.rules.perform(self.grid)
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
        
        var isCompletelyDead = true
        for cell in cells {
            if let hexagon = grid.hexagon(atLocation: cell.coordinate) {
                switch (cell.alive, hexagon.active) {
                case (false, true):
                    isCompletelyDead = false
                    cellsToActivate.append(cell)
                case (true, false):
                    cellsToDeactivate.append(cell)
                case (true, true):
                    isCompletelyDead = false
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
        if isCompletelyDead {
            self.stop()
            return
        }
    }

    
    // MARK: Timer
    func createTimer() -> NSTimer {
        return NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    func tick(timer: NSTimer) {
        updateGrid()
    }
    
    // MARK: Button
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
}

// MARK: HexagonView Delegate
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


//MARK: Shake!
extension ViewController {
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            stop()
            dispatch_async(gridQueue) {
                let grid = gridFromViewDimensions(self.view.bounds.size, cellSize: cellSize, gridType: .Empty)
                self.grid = grid
                dispatch_async(dispatch_get_main_queue()) {
                    self.drawGrid(grid)
                }
            }
        }
    }
}


//MARK: Menu
extension ViewController {
    func showMenu() {
        let menuView = MenuView(frame: view.frame)
        view.addSubview(menuView)
        self.menuView = menuView
    }
}

