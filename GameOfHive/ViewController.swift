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


let cellSize: CGSize = {
    let cellHeight: CGFloat = 26 // must be even!!!! We use half height and half width for drawing
    var cellWidth = (sqrt((3 * cellHeight * cellHeight) / 16)) * 2
    cellWidth = ceil(cellWidth) % 2 == 1 ? floor(cellWidth) : ceil(cellWidth)
    
    return CGSize(width: cellWidth, height: cellHeight)
}()

let sideLength = cellSize.height/2

let lineWidth: CGFloat = 1.0

class ViewController: UIViewController {
    var cells: [HexagonView] = []
    var timer: NSTimer!
    var grid: HexagonGrid!
    let rules = Rules.defaultRules

    let contentView = UIView()
    let buttonContainer = UIStackView()
    var buttonsVisibleConstraint: NSLayoutConstraint?
    var buttonsHiddenConstraint: NSLayoutConstraint?
    let playButton: UIButton = UIButton(type: .Custom)
    let saveButton = UIButton(type: .Custom)
    let menuButton = UIButton(type: .Custom)
    
    let messageOverlay = UIControl()
    let messageHUD = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
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
    
    var shouldShowMessage: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(contentView)
        view.addSubview(buttonContainer)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
        contentView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        contentView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        contentView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
        createGrid()
        
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonsVisibleConstraint = buttonContainer.topAnchor.constraintEqualToAnchor(view.topAnchor, constant: 25)
        buttonsHiddenConstraint = buttonContainer.bottomAnchor.constraintEqualToAnchor(view.topAnchor)
        buttonsVisibleConstraint?.active = true
        buttonContainer.leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: 25).active = true
        buttonContainer.axis = .Vertical
        buttonContainer.spacing = 10
        
        playButton.addTarget(self, action: #selector(togglePlayback(_:)), forControlEvents: .TouchUpInside)
		playButton.setImage(UIImage(named: "button_play"), forState: .Normal)
        
        saveButton.setImage(UIImage(named: "button_save"), forState: .Normal)
        menuButton.setImage(UIImage(named: "button_menu"), forState: .Normal)
        saveButton.addTarget(self, action: #selector(saveGrid), forControlEvents: .TouchUpInside)
        menuButton.addTarget(self, action: #selector(openMenu), forControlEvents: .TouchUpInside)
        
        buttonContainer.addArrangedSubview(playButton)
        buttonContainer.addArrangedSubview(saveButton)
        buttonContainer.addArrangedSubview(menuButton)
        
        let threeFingerTap = UITapGestureRecognizer(target: self, action: #selector(toggleButtons(_:)))
        threeFingerTap.numberOfTouchesRequired = 3
        contentView.addGestureRecognizer(threeFingerTap)
        
        view.addSubview(messageOverlay)
        messageOverlay.constrainToView(view)
        messageOverlay.addTarget(self, action: #selector(dismissMessageOverlay), forControlEvents: .TouchUpInside)
        
        
        messageOverlay.addSubview(messageHUD)
        messageHUD.userInteractionEnabled = false
        messageHUD.translatesAutoresizingMaskIntoConstraints = false
        messageHUD.centerXAnchor.constraintEqualToAnchor(messageOverlay.centerXAnchor).active = true
        messageHUD.centerYAnchor.constraintEqualToAnchor(messageOverlay.centerYAnchor).active = true
        messageHUD.heightAnchor.constraintEqualToAnchor(messageOverlay.heightAnchor, multiplier: 0.5).active = true
        messageHUD.heightAnchor.constraintEqualToAnchor(messageHUD.widthAnchor, multiplier: 1/(sqrt(3) / 2)).active = true

        let messageView = UILabel()

        messageHUD.contentView.addSubview(messageView)
        
        
        
        messageView.numberOfLines = 0
        messageView.adjustsFontSizeToFitWidth = true
        messageView.textAlignment = .Center
        messageView.constrainToView(messageHUD, margin: 20)
        messageView.text = "Tap with three fingers to show and hide the menu"
        messageView.font = UIFont(name: "Raleway-Medium", size: 20)
        messageView.textColor = UIColor.lightAmberColor
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let maskLayer = CAShapeLayer()
        maskLayer.path = hexagonPath(messageHUD.frame.size)
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = UIColor.lightAmberColor.CGColor
        borderLayer.lineWidth = 5
        borderLayer.fillColor = UIColor.clearColor().CGColor
        messageHUD.layer.mask = maskLayer
        messageHUD.layer.addSublayer(borderLayer)
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
        stop()
        grid = g
        drawGrid(grid, animationDuration: 0.2)
    }
    
    func openMenu() {
        stop()
        performSegueWithIdentifier("presentMenu", sender: self)
    }
    
    func toggleButtons(gestureRecognizer: UIGestureRecognizer) {
        buttonsVisibleConstraint?.active = !(buttonsVisibleConstraint?.active ?? false)
        buttonsHiddenConstraint?.active = !(buttonsHiddenConstraint?.active ?? false)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .BeginFromCurrentState, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func dismissMessageOverlay() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .BeginFromCurrentState, animations: {
            self.messageHUD.transform = CGAffineTransformMakeScale(0.01, 0.01)
            }) { finished in
            self.messageOverlay.removeFromSuperview()
        }
    }
    
    
    // MARK: Grid
    func createGrid() {
        assert(timer == nil, "Expect not running")
        assert(grid == nil, "Expect grid does not exist")

        grid = gridFromViewDimensions(view.bounds.size, cellSize: cellSize, gridType: .Random)

        let xOffset = -cellSize.width/2
        let yOffset = -(cellSize.height/4 + sideLength)
        
        grid.forEach { hexagon in
            let row = hexagon.location.row
            let column = hexagon.location.column
            let x = xOffset + (row & 1 == 0 ? (cellSize.width * CGFloat(column)) : (cellSize.width * CGFloat(column)) + (cellSize.width * 0.5))
            let y = yOffset + ((cellSize.height - sideLength/2) * CGFloat(row))
            let frame = CGRect(x: x, y: y, width: cellSize.width, height: cellSize.height)
            let cell = HexagonView(frame: frame)
            cell.coordinate = hexagon.location
            cell.alive = hexagon.active
            cell.alpha = cell.alive ? HexagonView.aliveAlpha : HexagonView.deadAlpha
            cell.hexagonViewDelegate = self
            cells.append(cell)
            contentView.addSubview(cell)
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
    
    func drawGrid(grid: HexagonGrid, animationDuration: Double = 0.05) {
        assert(NSThread.isMainThread(), "Expect main thread")
        
        // split cells by needed action. filter unchanged cells
        var cellsToActivate: [HexagonView] = []
        var cellsToDeactivate: [HexagonView] = []
        
        var isCompletelyDead = true
        cells.forEach { cell in
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
            let config = AnimationConfiguration(startValue: HexagonView.deadAlpha, endValue: HexagonView.aliveAlpha, duration: animationDuration)
            Animator.addAnimationForViews(cellsToActivate, configuration: config)
        }
        if cellsToDeactivate.count > 0 {
            let config = AnimationConfiguration(startValue: HexagonView.aliveAlpha, endValue: HexagonView.deadAlpha, duration: animationDuration)
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
    func togglePlayback(button: UIButton) {
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
        playButton.setImage(UIImage(named: "button_stop"), forState: .Normal)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        playButton.setImage(UIImage(named: "button_play"), forState: .Normal)
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
                let start: CGFloat = alive ? HexagonView.deadAlpha : HexagonView.aliveAlpha
                let end: CGFloat = alive ? HexagonView.aliveAlpha : HexagonView.deadAlpha
                let duration: CFTimeInterval = 0.2
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

