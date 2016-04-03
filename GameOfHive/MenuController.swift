//
//  MenuView.swift
//  GameOfHive
//
//  Created by Tomas Harkema on 21-05-15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

enum MenuPressedState {
  case Show
  case Hide
}

class MenuController: UIViewController {

    @IBOutlet weak var centerButton: HiveButton!

    var buttons = [HiveButton]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        addButtons()
        animateIn()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    let height: CGFloat = 200
    let offset: CGFloat = 4

    var initialPoint: CGPoint {
        // calculate initial degrees for offset
        let initial_x = ((height / 2.0) * sqrt(3.0) / 2.0) + (pow(offset, 2) / 2.0)
        let initial_y = (height / 2.0) + (pow(offset, 2) / 2.0)
        return CGPoint(x: initial_x, y: initial_y)
    }

    var degrees: CGFloat {
        return atan(initialPoint.x / initialPoint.y) * (180 / CGFloat(M_PI))
    }

    var distance: CGFloat {
        return sqrt(pow(initialPoint.x, 2) + pow(initialPoint.y, 2))
    }

    func pointForDegrees(offset: CGFloat, degrees: CGFloat) -> CGPoint {
        let xOff = offset * cos(degrees * (CGFloat(M_PI) / 180))
        let yOff = offset * sin(degrees * (CGFloat(M_PI) / 180))
        return CGPoint(x: xOff, y: yOff)
    }

    func addButtons() {

        let buttonNames = ["About", "Credits", "Video", "Templates", "Dingen", "Foo"]

        let buttonsAndCoordinates: [(String, CGPoint)] = buttonNames.enumerate().map { (idx, el) in
            let offsetDegrees = (CGFloat(idx - 90) * 60.0) + degrees
            let point = pointForDegrees(distance, degrees: offsetDegrees - 90)
            return (el, point)
        }

        let buttons = buttonsAndCoordinates.map { (string, point) -> HiveButton in
            let center = CGPoint(x: point.x + (self.view.frame.width / 2), y: point.y + (self.view.frame.height / 2))
            let rect = CGRect(x: center.x, y: center.y, width: height/2 * sqrt(3.0) / 2.0, height: height/2)

            let button = HiveButton(type: .Custom)
            button.frame = rect
            button.setTitle(string, forState: .Normal)
            button.titleLabel?.textColor = UIColor.blackColor()
            button.center = center
            return button
        }

        buttons.forEach { button in
            self.view.insertSubview(button, belowSubview: centerButton)
        }

        self.buttons = buttons
    }

  func showMenu() {
    animateMenuState(.Show)
  }

  func hideMenu() {
    animateMenuState(.Hide)
  }

  private func animateMenuState(pressedState: MenuPressedState, completion: (Bool -> ())? = nil) {
    switch pressedState {
    case .Show:
        self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0)
        centerButton.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI / 2)), CGFloat.min, CGFloat.min)
        self.buttons.enumerate().forEach { (idx, button) in

            let tx = self.view.center.x - button.center.x
            let ty = self.view.center.y - button.center.y

            let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
            let translate = CGAffineTransformMakeTranslation(tx, ty)
            let transform = CGAffineTransformConcat(rotation, translate)
            button.transform = transform
        }
    case .Hide:
        centerButton.transform = CGAffineTransformIdentity
        self.buttons.forEach { $0.transform = CGAffineTransformIdentity }
    }

    let options: UIViewAnimationOptions = (pressedState == MenuPressedState.Show) ? .CurveEaseIn : .CurveEaseOut

    UIView.animateWithDuration(1.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: options, animations: {
        switch pressedState {
        case .Show:
            self.centerButton.transform = CGAffineTransformIdentity
            self.buttons.forEach { $0.transform = CGAffineTransformIdentity }

        case .Hide:
            self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0)
            self.centerButton.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI / 2)), CGFloat.min, CGFloat.min)
            self.buttons.enumerate().forEach { (idx, button) in

                let tx = self.view.center.x - button.center.x
                let ty = self.view.center.y - button.center.y

                let rotation = CGAffineTransformMakeRotation(CGFloat(M_PI / 2))
                let translate = CGAffineTransformMakeTranslation(tx, ty)
                let transform = CGAffineTransformConcat(rotation, translate)
                let scale = CGAffineTransformConcat(CGAffineTransformMakeScale(0.0001, 0.0001), transform)
                button.transform = scale
            }
        }

        self.view.setNeedsDisplay()
    }, completion: completion)
  }

    func animateIn() {
        animateMenuState(.Show)
    }

    func animateOut() {
        animateMenuState(.Hide) { completed in
            if completed {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
        }
    }

    var isDismissing = false
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        if !isDismissing {
            isDismissing = true
            animateOut()
        }
    }
}