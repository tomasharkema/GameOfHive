//
//  HiveButton.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 02-04-16.
//  Copyright © 2016 Beetles. All rights reserved.
//

import UIKit

enum HiveButtonStyle: CGFloat {
    case Big = 18
    case Small = 14
}

@IBDesignable
class HiveButton: UIButton {

    // MARK: Lifecycle
    let backgroundView = UIView()
    
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
            updateLayers()
        }
    }

    private func initialize() {
        setNeedsLayout()
        layoutIfNeeded()

        titleLabel?.font = UIFont(name: "Raleway-Medium", size: style.rawValue)
        titleLabel?.adjustsFontSizeToFitWidth = true
        setTitleColor(UIColor.darkAmberColor, forState: .Normal)
        tintColor = UIColor.darkAmberColor

        insertSubview(backgroundView, belowSubview: titleLabel!)
        backgroundView.constrainToView(self)
        backgroundView.backgroundColor = UIColor.menuButtonBackgroundColor
        backgroundView.userInteractionEnabled = false
    }

    override func drawRect(rect: CGRect) {
        updateLayers()
    }

    func updateLayers() {
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
