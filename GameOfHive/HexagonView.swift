//
//  HiveView.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

protocol HexagonViewDelegate {
    func userDidUpateCellAtCoordinate(coordinate: Coordinate, alive:Bool)
}

class HexagonView: UIView {
    static var edgePath: CGMutablePathRef? = nil
    static var lineWidth: CGFloat = 1.0
    
    static func updateEdgePath(width: CGFloat, height: CGFloat, lineWidth: CGFloat) {
        self.lineWidth = lineWidth
        
        let s = height / 2.0
        let b = width / 2.0
        let a = (height - s) / 2.0
        
        let halfLineWidth = lineWidth / 2.0
        
        let edge = CGPathCreateMutable()
        CGPathMoveToPoint(edge, nil, b, halfLineWidth)
        CGPathAddLineToPoint(edge, nil, width - halfLineWidth, a)
        CGPathAddLineToPoint(edge, nil, width - halfLineWidth, a + s)
        CGPathAddLineToPoint(edge, nil, b, height - halfLineWidth)
        CGPathAddLineToPoint(edge, nil, halfLineWidth, a + s)
        CGPathAddLineToPoint(edge, nil, halfLineWidth, a)
        CGPathAddLineToPoint(edge, nil, b, halfLineWidth)
        
        edgePath = edge
    }
    
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
        hexagonViewDelegate?.userDidUpateCellAtCoordinate(coordinate, alive: alive)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        let strokeColor = UIColor.darkAmberColor
        let backGroundColor = UIColor.blackColor()
        let hunnyColor = UIColor.lightAmberColor

        // edge
        let lineWidth = HexagonView.lineWidth
        let edgePath = HexagonView.edgePath
        
        // hunny transform
        let height = rect.height
        let width = rect.width
        let tx = (width - (width * hunnyScaleFactor)) / 2
        let ty = (height - (height * hunnyScaleFactor)) / 2
        let hunnyTranslate = CGAffineTransformMakeTranslation(tx, ty)
        let hunnyScale = CGAffineTransformMakeScale(hunnyScaleFactor, hunnyScaleFactor)
        var hunnyTransform = CGAffineTransformConcat(hunnyScale, hunnyTranslate)
        
        //hunny path
        let hunny = CGPathCreateCopyByTransformingPath(edgePath, &hunnyTransform)

        // backGroundColor
        CGContextSaveGState(context)
        CGContextAddPath(context, edgePath)
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
        CGContextAddPath(context, edgePath)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
        
    }
}
