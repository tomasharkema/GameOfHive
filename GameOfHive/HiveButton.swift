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

    private func initialize() {
        background.contentMode = .ScaleAspectFit
        insertSubview(background, belowSubview: titleLabel!)
        tintColor = UIColor.blackColor()
    }
}
