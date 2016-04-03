//
//  HiveButton.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 02-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

@IBDesignable
class HiveButton: UIButton {

    // MARK: Lifecycle
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    override func prepareForInterfaceBuilder() {
        initialize()
    }

    override var frame: CGRect {
        didSet {
            backgroundView.frame = bounds
            updateLayers()
        }
    }

    override var highlighted: Bool {
        didSet {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .CurveEaseOut, animations: {
                let scale: CGFloat = self.highlighted ? 0.8 : 1.0
                self.transform = CGAffineTransformMakeScale(scale, scale)
            }, completion: nil)
        }
    }

    private func initialize() {
        setNeedsLayout()
        layoutIfNeeded()

        titleLabel?.font = UIFont(name: "Raleway-Medium", size: 14)
        setTitleColor(UIColor.lightAmberColor, forState: .Normal)
        tintColor = UIColor.lightAmberColor

        insertSubview(backgroundView, belowSubview: titleLabel!)
    }

    func updateLayers() {
        backgroundView.userInteractionEnabled = false
        let maskLayer = CAShapeLayer()
        maskLayer.path = hexagonPath(backgroundView.frame.size)
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = UIColor.lightAmberColor.CGColor
        borderLayer.lineWidth = 5
        borderLayer.fillColor = UIColor.clearColor().CGColor
        backgroundView.layer.mask = maskLayer
        backgroundView.layer.addSublayer(borderLayer)
    }
}
