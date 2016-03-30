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
    static var pathPrototype: CGMutablePathRef!
    static var size: CGSize!
    static var lineWidth: CGFloat = 1.0
    static let fillColor = UIColor.lightAmberColor
    
    static func updateEdgePath(size: CGSize, lineWidth: CGFloat) {
        self.lineWidth = lineWidth
        self.size = size
        
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
        pathPrototype = path
    }
    
    var coordinate = Coordinate(row: NSNotFound, column: NSNotFound)
    var alive: Bool = false

    var animationState: AnimationState = .Ready
    var fillPath: CGPathRef!
  
    weak var hexagonViewDelegate: HexagonViewDelegate?
  
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
        // inform delegate
        hexagonViewDelegate?.userDidUpateCell(self)
    }
    
    override func drawRect(rect: CGRect) {
        if fillPath == nil {
            return;
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, HexagonView.lineWidth)
        CGContextSetFillColorWithColor(context, HexagonView.fillColor.CGColor)
        CGContextAddPath(context, fillPath)
        CGContextFillPath(context)
        CGContextRestoreGState(context)
        
        //        CGContextSaveGState(context)
        //
        //        let path = CGPathCreateMutable()
        //        var bounds = self.bounds
        //        bounds.origin.x = bounds.midY
        //        bounds.origin.y = -bounds.midY
        //        CGPathAddRect(path, nil,  bounds)
        //
        //        let attString:NSAttributedString = NSAttributedString(string: "\(coordinate)", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        //        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        //        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        //        CGContextScaleCTM(context, 1.0, -1.0);
        //
        //        let framesetter = CTFramesetterCreateWithAttributedString(attString)
        //        var frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attString.length), path, nil)
        //        CTFrameDraw(frame, context)
        //
        //        CGContextRestoreGState(context)
        
        
        //        // edge
        //        CGContextSaveGState(context)
        //        CGContextAddPath(context, edgePath)
        //        CGContextSetLineWidth(context, lineWidth)
        //        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
        //        CGContextStrokePath(context)
        //        CGContextRestoreGState(context)
        //        
    }
}
