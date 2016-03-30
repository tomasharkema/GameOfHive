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
    case Animating(identifier: UInt32)
}

struct AnimationConfiguration {
    let startValue: CGFloat
    let endValue: CGFloat
    let duration: CFTimeInterval
    
    var delta: CGFloat {
        return endValue - startValue
    }
}

// MARK: Animation
private class ScaleAnimation {
    static var identifier : UInt32 = 0
    static func nextIdentifier() -> UInt32 {
        identifier = (identifier % UINT32_MAX) + 1
        return identifier
    }
    
    let identifier: UInt32
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
        self.identifier = ScaleAnimation.nextIdentifier()
        self.views = Set(views)
        self.start = configuration.startValue
        self.delta = configuration.delta
        self.endTime = configuration.duration
        
        // set state to animating
        views.forEach { $0.animationState = .Animating(identifier: self.identifier) }
    }
    
    func removeView(view: HexagonView) {
        view.animationState = .Ready
        views.remove(view)
        if views.count == 0 {
           delegate?.animationDidFinish(self)
        }
    }
    
    func increaseTime(increment: CFTimeInterval) {
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

// MARK: Animator
class Animator {
    private static let animator = Animator()
    private var displayLink: CADisplayLink!
    private var animations: [UInt32 : ScaleAnimation] = [:]
    private var lastDrawTime: CFTimeInterval = 0
    
    init () {
      displayLink = UIScreen.mainScreen().displayLinkWithTarget(self, selector: #selector(tick))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    // MARK: Add
    static func addAnimationForViews(views: [HexagonView], configuration: AnimationConfiguration) {
        // collect views ready for animation
        var ready: [HexagonView] = []
        for view in views {
            switch view.animationState {
            case .Ready:
                ready.append(view)
            case .Animating(let identifier):
                // pick up from current animation value when already .Animating. creates separate animations per view
                if let existingAnimation = animator.animations[identifier] {
                    // remove view from old animation
                    existingAnimation.removeView(view)
                    // add to new animation starting from current value
                    let config = AnimationConfiguration(startValue: existingAnimation.currentValue, endValue: configuration.endValue, duration: configuration.duration)
                    let newAnimation = ScaleAnimation(views: [view], configuration: config)
                    animator.addAnimation(newAnimation)
                }
                else {
                    assert(false, "Should not occur")
                    view.animationState = .Ready
                    ready.append(view)
                }
            }
        }
        
        // Start animating the views with animation state ready together in a single animation
        if ready.count > 0 {
            let animation = ScaleAnimation(views: ready, configuration: configuration)
            animator.addAnimation(animation)
        }
    }
    
    private func addAnimation(animation: ScaleAnimation) {
        animation.delegate = self
        animations[animation.identifier] = animation
    }
    
    // MARK: Display link
    @objc func tick(displayLink: CADisplayLink) {
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

// MARK: AnimationDelegate
extension Animator: AnimationDelegate {
    private func animationDidFinish(animation: ScaleAnimation) {
        animations[animation.identifier] = nil
    }
}
