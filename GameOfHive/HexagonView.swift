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

class HexagonView: UIView {
    static let lineWidth: CGFloat = 3.0
    static let path: CGPathRef = {
        let size = cellSize
        let height = size.height
        let width = size.width

        let s = height / 2.0
        let b = width / 2.0
        let a = (height - s) / 2.0
        
        let halfLineWidth = lineWidth / 2.0
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, b, halfLineWidth)
        CGPathAddLineToPoint(path, nil, width - halfLineWidth, a)
        CGPathAddLineToPoint(path, nil, width - halfLineWidth, a + s)
        CGPathAddLineToPoint(path, nil, b, height - halfLineWidth)
        CGPathAddLineToPoint(path, nil, halfLineWidth, a + s)
        CGPathAddLineToPoint(path, nil, halfLineWidth, a)
        CGPathAddLineToPoint(path, nil, b, halfLineWidth)
        return path
    }()

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
  
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        // invert alive
        self.alive = !self.alive
        // inform delegate
        hexagonViewDelegate?.userDidUpateCell(self)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, HexagonView.lineWidth)
        CGContextSetFillColorWithColor(context, HexagonView.fillColor.CGColor)
        CGContextAddPath(context, HexagonView.path)
        CGContextFillPath(context)
    }
}
