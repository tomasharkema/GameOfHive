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

class HexagonView: UIView {
    
    var coordinate = Coordinate(row: NSNotFound, column: NSNotFound)
    var alive: Bool = true
  
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

        let s = height / 2.0
        let b = width / 2.0
        let a = (height - s) / 2.0
        
        let lineWidth: CGFloat = 1.0
        let halfLineWidth: CGFloat = 0.0
        
        let edge = CGPathCreateMutable()
        CGPathMoveToPoint(edge, nil, b, halfLineWidth)
        CGPathAddLineToPoint(edge, nil, width - halfLineWidth, a)
        CGPathAddLineToPoint(edge, nil, width - halfLineWidth, a + s)
        CGPathAddLineToPoint(edge, nil, b, height - halfLineWidth)
        CGPathAddLineToPoint(edge, nil, halfLineWidth, a + s)
        CGPathAddLineToPoint(edge, nil, halfLineWidth, a)
        CGPathAddLineToPoint(edge, nil, b, halfLineWidth)
        
        let tx = (width / 2) - (width * hunnyScaleFactor) / 2
        let ty = (height / 2) - (height * hunnyScaleFactor) / 2
        let hunnyTranslate = CGAffineTransformMakeTranslation(tx, ty)
        let hunnyScale = CGAffineTransformMakeScale(hunnyScaleFactor, hunnyScaleFactor)
        var hunnyTransform = CGAffineTransformConcat(hunnyScale, hunnyTranslate)
        let hunny = CGPathCreateCopyByTransformingPath(edge, &hunnyTransform)

        // backGroundColor
        CGContextSaveGState(context)
        CGContextAddPath(context, edge)
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
        CGContextAddPath(context, edge)
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