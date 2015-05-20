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
        
      
        let path = CGPathCreateMutable()
        let height = rect.height
        let width = rect.width
        
        let strokeColor = UIColor.darkAmberColor
        let fillColor = alive ? UIColor.lightAmberColor : UIColor.blackColor()

        let s = height / 2.0
        let b = width / 2.0
        let a = (height - s) / 2.0
        
        let lineWidth: CGFloat = 1.0
        let halfLineWidth: CGFloat = 0.0
        
        CGPathMoveToPoint(path, nil, b, halfLineWidth)
        CGPathAddLineToPoint(path, nil, width - halfLineWidth, a)
        CGPathAddLineToPoint(path, nil, width - halfLineWidth, a + s)
        CGPathAddLineToPoint(path, nil, b, height - halfLineWidth)
        CGPathAddLineToPoint(path, nil, halfLineWidth, a + s)
        CGPathAddLineToPoint(path, nil, halfLineWidth, a)
        CGContextAddPath(context, path)
        CGContextClosePath(context)
        CGContextSetLineWidth(context, lineWidth)
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        CGContextSetFillColorWithColor(context, fillColor.CGColor)

        CGContextDrawPath(context, kCGPathFillStroke)
    }
}

class HiveView: UIView {
    static let width: CGFloat = 50
    static var height: CGFloat = 2 * (sqrt(0.5 * (0.5 * width)))
}