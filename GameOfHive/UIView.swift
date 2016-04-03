//
//  UIView.swift
//  GameOfHive
//
//  Created by Niels van Hoorn on 02/04/16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

extension UIView {
    func constrainToView(view: UIView, margin: CGFloat = 10) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraintEqualToAnchor(view.topAnchor, constant: margin).active = true
        bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -margin).active = true
        leftAnchor.constraintEqualToAnchor(view.leftAnchor, constant: margin).active = true
        rightAnchor.constraintEqualToAnchor(view.rightAnchor, constant: -margin).active = true
    }
    
    func captureScreenshot(scale scale: CGFloat) -> UIImage {
        let scaleTransform = CGAffineTransformMakeScale(scale, scale)
        let size = CGSizeApplyAffineTransform(self.bounds.size, scaleTransform)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        self.drawViewHierarchyInRect(rect, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}