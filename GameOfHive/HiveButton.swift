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
    let background = UIImageView(image: UIImage(named: "hexagon"))

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

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        background.frame = bounds
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
        background.contentMode = .ScaleAspectFit
        insertSubview(background, belowSubview: titleLabel!)
        titleLabel?.font = UIFont(name: "Raleway-Medium", size: 14)
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        tintColor = UIColor.blackColor()
    }
}
