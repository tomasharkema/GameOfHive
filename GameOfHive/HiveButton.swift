//
//  HiveButton.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 02-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

enum HiveButtonStyle: CGFloat {
    case Big = 20
    case Small = 14
}

@IBDesignable
class HiveButton: UIButton {

    // MARK: Lifecycle
    let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
    
    var style: HiveButtonStyle = .Big {
        didSet {
            titleLabel?.font = UIFont(name: "Raleway-Medium", size: style.rawValue)
        }
    }

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
//            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .CurveEaseOut, animations: {
//                let scale: CGFloat = self.highlighted ? 0.8 : 1.0
//                self.transform = CGAffineTransformMakeScale(scale, scale)
//            }, completion: nil)
        }
    }

    private func initialize() {
        setNeedsLayout()
        layoutIfNeeded()

        titleLabel?.font = UIFont(name: "Raleway-Medium", size: style.rawValue)
        setTitleColor(UIColor.darkAmberColor, forState: .Normal)
        tintColor = UIColor.darkAmberColor

        insertSubview(backgroundView, belowSubview: titleLabel!)
    }

    func updateLayers() {
        backgroundView.userInteractionEnabled = false
        let maskLayer = CAShapeLayer()
        maskLayer.path = hexagonPath(backgroundView.frame.size)
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskLayer.path
        borderLayer.strokeColor = UIColor.darkAmberColor.CGColor
        borderLayer.lineWidth = style == HiveButtonStyle.Big ? 5 : 2
        borderLayer.fillColor = UIColor.clearColor().CGColor
        backgroundView.layer.mask = maskLayer
        backgroundView.layer.addSublayer(borderLayer)
    }
}
