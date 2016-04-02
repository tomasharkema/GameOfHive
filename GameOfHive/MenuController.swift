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
  case HalfPressed
  case Hide
}

class MenuController: UIViewController {

    @IBOutlet weak var centerButton: HiveButton!

    var menuState = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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

        let buttons = ["About", "Credits", "Video", "Templates", "Dingen", "Foo"]

        let buttonsAndCoordinates: [(String, CGPoint)] = buttons.enumerate().map { (idx, el) in
            let offsetDegrees = (CGFloat(idx - 90) * 60.0) + degrees
            let point = pointForDegrees(distance, degrees: offsetDegrees - 90)
            return (el, point)
        }

        buttonsAndCoordinates.forEach { (string, point) in
            let center = CGPoint(x: point.x + (self.view.frame.width / 2), y: point.y + (self.view.frame.height / 2))
            let rect = CGRect(x: center.x, y: center.y, width: height/2 * sqrt(3.0) / 2.0, height: height/2)

            let button = HiveButton(type: .System)
            button.frame = rect
            self.view.addSubview(button)
            button.setTitle(string, forState: .Normal)
            button.center = center
        }
    }

  func showMenu() {
    menuState = true
    animateMenuState(.Show, animated: true)
  }

  func hideMenu() {
    menuState = false
    animateMenuState(.Hide, animated: true)
  }

  private func animateMenuState(pressedState: MenuPressedState, animated: Bool, completion: (Bool -> ())? = nil) {

    switch pressedState {
    case .Show:
        centerButton.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI / 2)), CGFloat.min, CGFloat.min)
    case .Hide:
        centerButton.transform = CGAffineTransformIdentity
    default:
        break
    }

    let animationBlock: Void -> Void = {
      
      switch pressedState {
      case .Show:
         self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0.9)
        self.centerButton.transform = CGAffineTransformIdentity
      case .HalfPressed:
        self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0.2)
        self.centerButton.transform = CGAffineTransformMakeScale(0.50, 0.50)
      case .Hide:
        self.view.backgroundColor = UIColor.backgroundColor.colorWithAlphaComponent(0)
        self.centerButton.transform = CGAffineTransformMakeScale(0.0000001, 0.0000001)
      }

      self.view.setNeedsDisplay()
    }
    
    if animated {
      
      switch pressedState {
      case .HalfPressed:
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .CurveEaseOut, animations: animationBlock, completion: completion)
      default:
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .CurveEaseIn, animations: animationBlock, completion: completion)
      }
      
    } else {
      animationBlock()
    }
  }

    func animateIn() {
        addButtons()
        animateMenuState(.Show, animated: true)
    }

    func animateOut() {
        animateMenuState(.Hide, animated: true) { completed in
            if completed {
//                self.removeFromSuperview()
            }
        }
    }

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        animateOut()
    }
}