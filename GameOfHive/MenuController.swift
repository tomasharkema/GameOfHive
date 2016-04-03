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

protocol MenuDelegate: class {
    func menuWillClose(menu: MenuController)
}

enum Content {
    case Webpage(NSURL)
}

struct MenuItemModel {
    let title: String
    let content: Content
}

class MenuController: UIViewController {

    @IBOutlet weak var centerButton: HiveButton!
    
    weak var delegate: MenuDelegate?

    private let buttonModels = [
        MenuItemModel(
            title: "About",
            content: .Webpage(NSURL(string: "https://tomasharkema.github.io/GameOfHive/about.html")!)),
        MenuItemModel(
            title: "Credits",
            content: .Webpage(NSURL(string: "https://tomasharkema.github.io/GameOfHive/credits.html")!)),
        MenuItemModel(
            title: "Templates",
            content: .Webpage(NSURL(string: "https://tomasharkema.github.io/GameOfHive/")!)),
        MenuItemModel(
            title: "Saved Grids",
            content: .Webpage(NSURL(string: "https://tomasharkema.github.io/GameOfHive/")!)),
        MenuItemModel(
            title: "Donate",
            content: .Webpage(NSURL(string: "https://tomasharkema.github.io/GameOfHive/donate.html")!)),
        MenuItemModel(
            title: "Video",
            content: .Webpage(NSURL(string: "https://tomasharkema.github.io/GameOfHive/video.html")!))]


    private var buttons = [HiveButton]()
    private var openedHive: HiveButton?
    private var height: CGFloat = 200

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        // because, you know, constraints...
        height = centerButton.bounds.height

        addButtons()
        animateIn()
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.LandscapeLeft,.LandscapeRight]
    }

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

        let buttonsAndCoordinates: [(MenuItemModel, CGPoint)] = buttonModels.enumerate().map { (idx, el) in
            let offsetDegrees = (CGFloat(idx - 90) * 60.0) + degrees
            let point = pointForDegrees(distance, degrees: offsetDegrees - 90)
            return (el, point)
        }

        let buttons = buttonsAndCoordinates.map { (model, point) -> HiveButton in
            let center = CGPoint(x: point.x + (self.view.frame.width / 2), y: point.y + (self.view.frame.height / 2))
            let rect = CGRect(x: center.x, y: center.y, width: height/2 * sqrt(3.0) / 2.0, height: height/2)

            let button = HiveButton(type: .Custom)
            button.style = .Small
            button.frame = rect
            button.setTitle(model.title, forState: .Normal)
            button.titleLabel?.textColor = UIColor.blackColor()
            button.center = center
            button.addTarget(self, action: #selector(buttonPressed), forControlEvents: .TouchUpInside)
            return button
        }

        buttons.forEach { button in
            self.view.insertSubview(button, belowSubview: centerButton)
        }

        self.buttons = buttons
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

        let animations = {
            switch pressedState {
            case .Show:
                self.centerButton.transform = CGAffineTransformIdentity
                self.buttons.forEach { $0.transform = CGAffineTransformIdentity }

            case .Hide:
                self.centerButton.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(CGFloat(M_PI / 2)), 0.01, 0.01)
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
        }
        
        switch pressedState {
        case .Show:
            UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .CurveEaseIn, animations: animations, completion: completion)

        case .Hide:
            UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseIn, animations: animations, completion: completion)
        }


        UIView.animateWithDuration(0.4) {
            self.view.backgroundColor = UIColor.backgroundColor
                .colorWithAlphaComponent(pressedState == MenuPressedState.Show ? 0.6 : 0)
        }
    }
    
    func animateIn() {
        animateMenuState(.Show)
    }
    
    func animateOut() {
        delegate?.menuWillClose(self)
        animateMenuState(.Hide) { completed in
            if completed {
                self.dismissViewControllerAnimated(false, completion: nil)
            }
        }
    }
    
    var isDismissing = false
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        guard !isDismissing else {
            return
        }

        isDismissing = true
        animateOut()
    }
}

//MARK: Menu Button Handling

extension MenuController: ContentDelegate {
    func animateButtonToControllerPoint(hiveButton: HiveButton, completion: ((Bool) -> ())?) {
        let endX = (hiveButton.frame.width / 2) + 30
        let endY = (hiveButton.frame.height / 2) + 30

        let tx = endX - hiveButton.center.x
        let ty = endY - hiveButton.center.y
        let _: Double = sqrt(pow(Double(tx), 2) + pow(Double(ty), 2))

        UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseOut], animations: {
            hiveButton.transform = CGAffineTransformMakeTranslation(tx, ty)
        }, completion: completion)
    }

    func buttonPressed(hiveButton: HiveButton) {
        openedHive = hiveButton

        guard let item = buttonModels.filter({ $0.title == hiveButton.titleForState(.Normal) }).first else {
            return
        }

        switch item.content {
        case .Webpage:
            performSegueWithIdentifier("presentContentController", sender: self)

            animateButtonToControllerPoint(hiveButton) { _ in }
        }
    }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    guard let destination = segue.destinationViewController as? ContentViewController where segue.identifier == "presentContentController" else {
      return
    }

    guard let item = buttonModels.filter({ $0.title == self.openedHive?.titleForState(.Normal) }).first else {
        return
    }

    switch item.content {
    case let .Webpage(url):
        destination.leftOffset = height/2 * sqrt(3.0) / 2.0
        destination.webView.loadRequest(NSURLRequest(URL: url))
    }

    destination.delegate = self
  }

  func contentWillClose(menu: ContentViewController) {
    UIView.animateWithDuration(0.3, delay: 0, options: [.CurveEaseOut], animations: {
        self.openedHive?.transform = CGAffineTransformIdentity
    }, completion: nil)
  }
}