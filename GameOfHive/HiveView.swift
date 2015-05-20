//
//  HiveView.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

// amber
extension UIColor {
    static var lightAmberColor : UIColor {
        return UIColor(red: 1.0, green: 0.7490196078, blue: 0, alpha: 1)
    }
    
    static var darkAmberColor : UIColor {
        return UIColor(red: 1.0, green: 0.4941176471, blue: 0, alpha: 1)
    }
}

protocol HexagonViewDelegate {
  func userDidUpateCellAtCoordinate(coordinate: Coordinate, alive:Bool)
}

protocol ScaleAnimationDelegate: class {
    func animationDidFinish(animation: ScaleAnimation)
}

func == (lhs: ScaleAnimation, rhs: ScaleAnimation) -> Bool {
    return lhs.view == rhs.view
}

class ScaleAnimation: Equatable {
    unowned var view: HexagonView
    weak var delegate: ScaleAnimationDelegate?
    
    let start: CGFloat
    let delta: CGFloat
    
    let time: CFTimeInterval
    var currentTime: CFTimeInterval = 0.0

    init (view: HexagonView, end: CGFloat, time: CFTimeInterval) {
        self.view = view
        start = view.hunnyScaleFactor
        delta = end - start
        self.time = time
    }
    
    func increaseTime(time: CFTimeInterval) {
        currentTime += time
        if currentTime > self.time {
            currentTime = self.time
        }
        
        let factor = CGFloat(currentTime / self.time)
        let scale = start + delta * factor
        
//        println("scale \(scale) factor \(factor)")
        view.hunnyScaleFactor = scale
        view.setNeedsDisplay()
        
        if currentTime >= self.time {
            delegate?.animationDidFinish(self)
        }
    }
}

@objc class Animator: ScaleAnimationDelegate {
    
    static let animator = Animator()
    
    var displayLink: CADisplayLink! = nil
    var animations: [ScaleAnimation] = []
    
    init () {
        displayLink = UIScreen.mainScreen().displayLinkWithTarget(self, selector: Selector("tick:"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func addAnimationForView(view: HexagonView, end: CGFloat) {
        var animation = ScaleAnimation(view: view, end: end, time: 0.08)
        animation.delegate = self
        animations.append(animation)
    }
    
    func tick(displayLink: CADisplayLink) {
        let duration = displayLink.duration
        for animation in animations {
            animation.increaseTime(duration)
        }
    }
    
    func animationDidFinish(animation: ScaleAnimation) {
        if let index = find(animations, animation) {
            animations.removeAtIndex(index)
        }
    }
}

class HexagonView: UIView {
    var path: CGMutablePathRef?
    var coordinate = Coordinate(row: NSNotFound, column: NSNotFound)
    var alive: Bool = true {
        didSet {
            if alive != oldValue {
                let end: CGFloat = alive ? 1.0 : 0.0
                Animator.animator.addAnimationForView(self, end: end)
            }
        }
    }
  
    var hexagonViewDelegate: HexagonViewDelegate?
    var hunnyScaleFactor: CGFloat = 1.0
  
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
  
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
      super.touchesBegan(touches, withEvent: event)
      self.alive = !self.alive
      self.setNeedsDisplay()
      println("TOUCH: \(coordinate) \(alive)")
      hexagonViewDelegate?.userDidUpateCellAtCoordinate(coordinate, alive: alive)
    }
      
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let height = rect.height
        let width = rect.width

        let strokeColor = UIColor.darkAmberColor
        let backGroundColor = UIColor.blackColor()
        let hunnyColor = UIColor.lightAmberColor

        let lineWidth: CGFloat = 1.0

        if path == nil {


            let s = height / 2.0
            let b = width / 2.0
            let a = (height - s) / 2.0
            
            let halfLineWidth: CGFloat = 0.0
        
            let edge = CGPathCreateMutable()
            CGPathMoveToPoint(edge, nil, b, halfLineWidth)
            CGPathAddLineToPoint(edge, nil, width - halfLineWidth, a)
            CGPathAddLineToPoint(edge, nil, width - halfLineWidth, a + s)
            CGPathAddLineToPoint(edge, nil, b, height - halfLineWidth)
            CGPathAddLineToPoint(edge, nil, halfLineWidth, a + s)
            CGPathAddLineToPoint(edge, nil, halfLineWidth, a)
            CGPathAddLineToPoint(edge, nil, b, halfLineWidth)
            path = edge
        }
        
        let tx = (width / 2) - (width * hunnyScaleFactor) / 2
        let ty = (height / 2) - (height * hunnyScaleFactor) / 2
        let hunnyTranslate = CGAffineTransformMakeTranslation(tx, ty)
        let hunnyScale = CGAffineTransformMakeScale(hunnyScaleFactor, hunnyScaleFactor)
        var hunnyTransform = CGAffineTransformConcat(hunnyScale, hunnyTranslate)
        let hunny = CGPathCreateCopyByTransformingPath(path, &hunnyTransform)

        // backGroundColor
        CGContextSaveGState(context)
        CGContextAddPath(context, path)
        CGContextSetFillColorWithColor(context, backGroundColor.CGColor)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        // hunny
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetFillColorWithColor(context, hunnyColor.CGColor)
        CGContextAddPath(context, hunny)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        // edge
        CGContextSaveGState(context)
        CGContextAddPath(context, path)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
        
    }
}

class HiveView: UIView {
    static let width: CGFloat = 50
    static var height: CGFloat = 2 * (sqrt(0.5 * (0.5 * width)))
}