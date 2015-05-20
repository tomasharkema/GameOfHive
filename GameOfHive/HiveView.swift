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

private let sqrtƷ = CGFloat(sqrt(3.0))

class HexagonView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let path = CGPathCreateMutable()
        let height = rect.height
        let width = rect.width

        let s = height/(sqrtƷ)
        let b = width / 2.0
        let a = sqrt(s*s - b*b)
        
        CGPathMoveToPoint(path, nil, b, 0)
        CGPathAddLineToPoint(path, nil, width, a)
        CGPathAddLineToPoint(path, nil, width, a + s)
        CGPathAddLineToPoint(path, nil, b, height)
        CGPathAddLineToPoint(path, nil, 0, a + s)
        CGPathAddLineToPoint(path, nil, 0, a)
        CGContextAddPath(context, path)
        CGContextClosePath(context)
        CGContextSetLineWidth(context, 2)
        CGContextSetStrokeColorWithColor(context, UIColor.darkAmberColor.CGColor)
        CGContextSetFillColorWithColor(context, UIColor.lightAmberColor.CGColor)

        CGContextDrawPath(context, kCGPathStroke)
    }
}

class HiveView: UIView {
    override func drawRect(rect: CGRect) {
        
    }
}