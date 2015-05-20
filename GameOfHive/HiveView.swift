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
