//
//  Animations.swift
//  GameOfHive
//
//  Created by Taco Vollmer on 20/05/15.
//  Copyright (c) 2015 Beetles. All rights reserved.
//

import UIKit

private protocol AnimationDelegate: class {
    func animationDidFinish(animation: ScaleAnimation)
}

enum AnimationState {
    case Ready
    case Animating(identifier: Int)
}

struct AnimationConfiguration {
    let startValue: CGFloat
    let endValue: CGFloat
    let duration: CFTimeInterval
    
    var delta: CGFloat {
        return endValue - startValue
    }
}

private class ScaleAnimation {
    static var identifier : Int = 0
    let identifier: Int
    var views = Set<HexagonView>()
    weak var delegate: AnimationDelegate?
    
    // values
    let start: CGFloat
    let delta: CGFloat
    var currentValue: CGFloat = 0
    
    // time
    let endTime: CFTimeInterval
    var currentTime: CFTimeInterval = 0
    
    init (views: [HexagonView], configuration:AnimationConfiguration) {
        self.identifier = ++ScaleAnimation.identifier
        self.views = Set(views)
        self.start = configuration.startValue
        self.delta = configuration.delta
        self.endTime = configuration.duration
        
        // set state to animating
        views.map { $0.animationState = .Animating(identifier: self.identifier) }
    }
    
    private func increaseTime(increment: CFTimeInterval) {
        currentTime += increment
        
        // clip to endtime
        if currentTime > endTime {
            currentTime = endTime
        }
        
        // calculate current value
        let factor = CGFloat(currentTime / endTime)
        currentValue = start + delta * factor
        
        // create transform
        let size = HexagonView.size
        let height = size.height
        let width = size.width
        let tx = (width - (width * currentValue)) / 2
        let ty = (height - (height * currentValue)) / 2
        let translationTransform = CGAffineTransformMakeTranslation(tx, ty)
        let scaleTransform = CGAffineTransformMakeScale(currentValue, currentValue)
        var totalTransform = CGAffineTransformConcat(scaleTransform, translationTransform)
        let path = CGPathCreateCopyByTransformingPath(HexagonView.pathPrototype, &totalTransform)

        // draw fill
        for view in views {
            view.fillPath = path
            view.setNeedsDisplay()
        }
        
        // finish if end time is reached
        if currentTime >= endTime {
            // reset animation state to .Ready
            for view in views {
                view.animationState = .Ready
            }
            
            // inform delegate
            delegate?.animationDidFinish(self)
        }
    }
}

@objc class Animator {
    private static let animator = Animator()
    private var displayLink: CADisplayLink!
    private var animations: [Int : ScaleAnimation] = [:]
    private var lastDrawTime: CFTimeInterval = 0
    
    init () {
        displayLink = UIScreen.mainScreen().displayLinkWithTarget(self, selector: Selector("tick:"))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
        
    static func addAnimationForViews(views: [HexagonView], configuration: AnimationConfiguration) {
        // split by animation state
        var ready: [HexagonView] = []
        var animating: [HexagonView] = []
        
        for view in views {
            switch view.animationState {
            case .Ready:
                ready.append(view)
            case .Animating(let identifier):
                // pick up from current animation value when already .Animating. creates separate animations per view
                if let existingAnimation = animator.animations[identifier] {
                    // remove view from old animation, if old animation becomes empty remove it entirely
                    existingAnimation.views.remove(view)
                    if existingAnimation.views.count == 0 {
                        animator.animations[identifier] = nil
                    }
                    
                    // add to new animation starting from current value
                    let config = AnimationConfiguration(startValue: existingAnimation.currentValue, endValue: configuration.endValue, duration: configuration.duration)
                    let newAnimation = ScaleAnimation(views: [view], configuration: config)
                    newAnimation.delegate = animator
                    animator.animations[newAnimation.identifier] = newAnimation
                }
            }
        }
        
        // start animating the .Ready views together in one animation
        if ready.count > 0 {
            let animation = ScaleAnimation(views: ready, configuration: configuration)
            animation.delegate = animator
            animator.animations[animation.identifier] = animation
        }
    }
    
    // display link
    func tick(displayLink: CADisplayLink) {
        if lastDrawTime == 0 {
            lastDrawTime = displayLink.timestamp
        }
        
        let duration = displayLink.timestamp - lastDrawTime
        
        for (_, animation) in animations {
            animation.increaseTime(duration)
        }
        
        lastDrawTime = displayLink.timestamp
    }
}

extension Animator: AnimationDelegate {
    private func animationDidFinish(animation: ScaleAnimation) {
        animations[animation.identifier] = nil
    }
}
