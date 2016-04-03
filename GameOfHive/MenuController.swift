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

    func addButtons() {

        let height: CGFloat = 200
        let offset: CGFloat = 4

        // calculate initial degrees for offset
        let initial_x = ((height / 2.0) * sqrt(3.0) / 2.0) + (pow(offset, 2) / 2.0)
        let initial_y = (height / 2.0) + (pow(offset, 2) / 2.0)
        let distance = sqrt(pow(initial_x, 2) + pow(initial_y, 2))

        let degrees = atan(initial_x / initial_y) * (180 / CGFloat(M_PI))

        func pointForDegrees(offset: CGFloat, degrees: CGFloat) -> CGPoint {
            let xOff = offset * cos(degrees * (CGFloat(M_PI) / 180))
            let yOff = offset * sin(degrees * (CGFloat(M_PI) / 180))
            return CGPoint(x: xOff, y: yOff)
        }

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
            self.view.addSubview(button)
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
        self.buttons.forEach { $0.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI / 2)), CGFloat.min, CGFloat.min) }
    case .Hide:
        centerButton.transform = CGAffineTransformIdentity
        self.buttons.forEach { $0.transform = CGAffineTransformIdentity }
    }

    let animationBlock: Void -> Void = {
      
      switch pressedState {
      case .Show:
         self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0.7)
         self.centerButton.transform = CGAffineTransformIdentity
         self.buttons.forEach { $0.transform = CGAffineTransformIdentity }

      case .Hide:
        self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0)
        self.centerButton.transform = CGAffineTransformMakeScale(0.0000001, 0.0000001)
        self.buttons.forEach { $0.transform = CGAffineTransformMakeScale(0.0000001, 0.0000001) }
      }

      self.view.setNeedsDisplay()
    }
    
    UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .CurveEaseIn, animations: animationBlock, completion: completion)
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

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        animateOut()
    }
}