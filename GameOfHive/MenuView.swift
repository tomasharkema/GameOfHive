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

class MenuView: UIView {
  
  let hexagonImageView = UIImageView(image: UIImage(named: "hexagon"))
  
  var menuState = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    hexagonImageView.frame = frame
    hexagonImageView.contentMode = .Center
    
    addSubview(hexagonImageView)
    
    animateMenuState(.Hide, animated: false)
    
    let tgr = UILongPressGestureRecognizer(target: self, action: Selector("tap:"))
    addGestureRecognizer(tgr)
  }
  
  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func showMenu() {
    menuState = true
    animateMenuState(.Show, animated: true)
  }
  func hideMenu() {
    menuState = false
    animateMenuState(.Hide, animated: true)
  }
  
  func tap(recognizer: UILongPressGestureRecognizer) {
    
    switch recognizer.state {
    case .Began:
        animateMenuState(.HalfPressed, animated: true)
    case .Cancelled, .Failed:
      animateMenuState(menuState == true ? .Show : .Hide, animated: true)
    case .Ended:
      animateMenuState(menuState == false ? .Show : .Hide, animated: true)
      menuState = !menuState
    default:()
    }
  }
  
  private func animateMenuState(pressedState: MenuPressedState, animated: Bool) {
    
    let animationBlock: Void -> Void = {
      
      switch pressedState {
      case .Show:
         self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        self.hexagonImageView.transform = CGAffineTransformIdentity
      case .HalfPressed:
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        self.hexagonImageView.transform = CGAffineTransformMakeScale(0.50, 0.50)
      case .Hide:
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        self.hexagonImageView.transform = CGAffineTransformMakeScale(0, 0)
      }
      
      //self.hexagonImageView.transform = animateIn ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0, 0)
      self.setNeedsDisplay()
    }
    
    if animated {
      
      switch pressedState {
      case .HalfPressed:
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, options: .CurveEaseOut, animations: animationBlock, completion: nil)
      default:
        UIView.animateWithDuration(1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: .CurveEaseOut, animations: animationBlock, completion: nil)
      }
      
    } else {
      animationBlock()
    }
  }
  
}