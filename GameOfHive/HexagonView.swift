//
//  HiveView.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

protocol HexagonViewDelegate: class {
    func userDidUpateCell(cell: HexagonView)
}

func hexagonPath(size: CGSize, lineWidth: CGFloat = 0) -> CGPath {
        let height = size.height
        let width = size.width
        
        // points numbered like this:
    	//
        //     1
        //  6     2
    	//
        //  5     3
        //	   4
        
        let topBottomOffset = (sqrt((3 * lineWidth * lineWidth) / 4))
        
        let p1 = CGPointMake(width / 2.0, topBottomOffset)
        let p2 = CGPointMake(width - (lineWidth / 2), height / 4)
        let p3 = CGPointMake(p2.x, p2.y * 3)
        let p4 = CGPointMake(p1.x, height - topBottomOffset)
        let p5 = CGPointMake(lineWidth / 2, p3.y)
        let p6 = CGPointMake(p5.x, p2.y)
        
    
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, p1.x, p1.y)
        CGPathAddLineToPoint(path, nil, p2.x, p2.y)
        CGPathAddLineToPoint(path, nil, p3.x, p3.y)
        CGPathAddLineToPoint(path, nil, p4.x, p4.y)
        CGPathAddLineToPoint(path, nil, p5.x, p5.y)
    
        CGPathAddLineToPoint(path, nil, p6.x, p6.y)
    	CGPathCloseSubpath(path)
    
        return path
}

class HexagonView: UIView {
    static let path: CGPathRef = hexagonPath(cellSize, lineWidth: lineWidth)

    static let fillColor = UIColor.lightAmberColor
    
    static let aliveAlpha: CGFloat = 1
    static let deadAlpha: CGFloat = 0.15
    
    var coordinate = Coordinate(row: NSNotFound, column: NSNotFound)
    var alive: Bool = false

    var animationState: AnimationState = .Ready
    
    weak var hexagonViewDelegate: HexagonViewDelegate?
  
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.alpha = HexagonView.deadAlpha
        self.backgroundColor = UIColor.clearColor()
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        guard let touch = touches.first where touches.count == 1 && CGPathContainsPoint(HexagonView.path, nil, touch.locationInView(self), false) else {
            return
    }
        // invert alive
        self.alive = !self.alive
        // inform delegate
        hexagonViewDelegate?.userDidUpateCell(self)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return CGPathContainsPoint(HexagonView.path, nil, point, false)
    }

    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetFillColorWithColor(context, HexagonView.fillColor.CGColor)
        CGContextAddPath(context, HexagonView.path)
        CGContextFillPath(context)
    }
}
