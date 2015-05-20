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
    
    let time: CFTimeInterval
    var currentTime: CFTimeInterval = 0.0
    
    init (view: HexagonView, end: CGFloat, time: CFTimeInterval) {
        self.view = view
        start = view.hunnyScaleFactor
        delta = end - start
        self.time = time
    }
    
    func increaseTime(time: CFTimeInterval) {
        currentTime += time
        if currentTime > self.time {
            currentTime = self.time
        }
        
        let factor = CGFloat(currentTime / self.time)
        let scale = start + delta * factor
        
        //        println("scale \(scale) factor \(factor)")
        view.hunnyScaleFactor = scale
        view.setNeedsDisplay()
        
        if currentTime >= self.time {
            delegate?.animationDidFinish(self)
        }
    }
}

@objc class Animator: ScaleAnimationDelegate {
    
    static let animator = Animator()
    
    var displayLink: CADisplayLink! = nil
    var animations: [ScaleAnimation] = []
    
    init () {
        displayLink = UIScreen.mainScreen().displayLinkWithTarget(self, selector: Selector("tick:"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func addAnimationForView(view: HexagonView, end: CGFloat) {
        var animation = ScaleAnimation(view: view, end: end, time: 0.08)
        animation.delegate = self
        animations.append(animation)
    }
    
    func tick(displayLink: CADisplayLink) {
        let duration = displayLink.duration
        for animation in animations {
            animation.increaseTime(duration)
        }
    }
    
    func animationDidFinish(animation: ScaleAnimation) {
        if let index = find(animations, animation) {
            animations.removeAtIndex(index)
        }
    }
}
