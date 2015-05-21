//
//  Animations.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

protocol ScaleAnimationDelegate: class {
    func animationDidFinish(animation: ScaleAnimation)
}

func == (lhs: ScaleAnimation, rhs: ScaleAnimation) -> Bool {
    return lhs.view == rhs.view
}

class ScaleAnimation: Equatable {
    unowned var view: HexagonView
    weak var delegate: ScaleAnimationDelegate?
    
    let start: CGFloat
    let delta: CGFloat
    
    let endTime: CFTimeInterval
    var currentTime: CFTimeInterval = 0.0
    
    init (view: HexagonView, end: CGFloat, time: CFTimeInterval) {
        self.view = view
        start = view.hunnyScaleFactor
        delta = end - start
        self.endTime = time
    }
    
    func increaseTime(time: CFTimeInterval) {
        currentTime += time
        if currentTime > self.endTime {
            currentTime = self.endTime
        }
        
        let factor = CGFloat(currentTime / self.endTime)
        let scale = start + delta * factor
        
        view.hunnyScaleFactor = scale
        view.setNeedsDisplay()
        
        if currentTime >= self.endTime {
            delegate?.animationDidFinish(self)
        }
    }
}

@objc class Animator: ScaleAnimationDelegate {
    
    static let animator = Animator()
    
    var displayLink: CADisplayLink! = nil
    var animations: [ScaleAnimation] = []
    var lastDrawTime: CFTimeInterval = 0
    
    init () {
        displayLink = UIScreen.mainScreen().displayLinkWithTarget(self, selector: Selector("tick:"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func addAnimationForView(view: HexagonView, end: CGFloat) {
        var animation = ScaleAnimation(view: view, end: end, time: 0.4)
        animation.delegate = self
        animations.append(animation)
    }
    
    func tick(displayLink: CADisplayLink) {
        if lastDrawTime == 0 {
            lastDrawTime = displayLink.timestamp
        }
        let duration = displayLink.timestamp - lastDrawTime
        for animation in animations {
            animation.increaseTime(duration)
        }
        lastDrawTime = displayLink.timestamp
    }
    
    func animationDidFinish(animation: ScaleAnimation) {
        if let index = find(animations, animation) {
            animations.removeAtIndex(index)
        }
    }
}
