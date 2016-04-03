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
    let rules = Rules.defaultRules
    
    var grid: HexagonGrid!
    var cells: [HexagonView] = []
    var timer: NSTimer!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet var contentView: UIView!
    @IBOutlet var buttonsVisibleConstraint: NSLayoutConstraint?
    @IBOutlet var buttonsHiddenConstraint: NSLayoutConstraint?

    var playing: Bool {
        return timer != nil
    }
    
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
        print(buttonsHiddenConstraint?.active,buttonsVisibleConstraint?.active)
        createGrid()

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
    
    func saveGrid(filename: String = "grid.json") {
        do { try grid.save(filename) } catch let error {
            print("Error saving grid",error)
        }
    }
    
    func loadGrid(filename: String = "grid.json") {
        guard let g = HexagonGrid.load(filename) else {
            return
        }
        stop()
        grid = g
        drawGrid(grid, animationDuration: 0.1)
    }
    
    func openMenu() {
        stop()
        performSegueWithIdentifier("presentMenu", sender: self)
    }
    
    func toggleButtons(gestureRecognizer: UIGestureRecognizer) {
        if let constraint = buttonsVisibleConstraint where constraint.active {
            buttonsVisibleConstraint?.active = false
            buttonsHiddenConstraint?.active = true
        } else if let constraint = buttonsHiddenConstraint where constraint.active {
            buttonsHiddenConstraint?.active = false
            buttonsVisibleConstraint?.active = true
        }
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
    
    private func start() {
        timer?.invalidate()
        timer = createTimer()
        timer.fire()
        playButton.setImage(UIImage(named: "button_stop"), forState: .Normal)
    }
    
    private func stop() {
        guard playing else {
            return
        }
        
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

extension ViewController {
    @IBAction func togglePlayback() {
        if playing {
            stop()
        } else {
            saveGrid("undo.json")
            start()
        }
    }
    
    @IBAction func didTapUndo(sender: UIButton) {
        loadGrid("undo.json")
    }
    
    @IBAction func didTapStep(sender: UIButton) {
        stop()
        updateGrid()
    }
    
    @IBAction func didTapLoad(sender: UIButton) {
        loadGrid()
    }
    
    @IBAction func didTapSave(sender: UIButton) {
        saveGrid()
    }
    
    @IBAction func didTapMenu(sender: UIButton) {
        openMenu()
    }
}

