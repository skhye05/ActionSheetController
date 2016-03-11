//
//  PresentTranslucentAnimation.swift
//  ActionSheetController
//
//  Created by Moch Xiao on 3/10/16.
//  Copyright © @2016 Moch Xiao (https://github.com/cuzv).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

public final class PresentTranslucentAnimation: NSObject {    
    private var presentedAnimation: Bool = false
    private var transitionCoverView: UIView?
    
    public typealias AnimationClosure = (fromView: UIView, toView: UIView) -> ()
    
    private var preparePresentAnimation: AnimationClosure? = nil
    private var presentAnimation: AnimationClosure? = nil
    private var prepareDismissAnimation: AnimationClosure? = nil
    private var dismissAnimation: AnimationClosure? = nil
    
    public init(preparePresentAnimation: AnimationClosure? = nil,
        presentAnimation: AnimationClosure? = nil,
        prepareDismissAnimation: AnimationClosure? = nil,
        dismissAnimation: AnimationClosure? = nil)
    {
        self.preparePresentAnimation = preparePresentAnimation
        self.presentAnimation = presentAnimation
        self.prepareDismissAnimation = prepareDismissAnimation
        self.dismissAnimation = dismissAnimation
    }
    
    public func prepareForPresent() -> Self {
        presentedAnimation = true
        return self
    }
    
    public func prepareForDismiss() -> Self {
        presentedAnimation = false
        return self
    }
}

// MARK: UIViewControllerAnimatedTransitioning

extension PresentTranslucentAnimation: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.25
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // MARK: Local methods
        func createCoverView(frame: CGRect) -> UIView {
            let coverView = UIView(frame: frame)
            coverView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
            coverView.alpha = 0
            coverView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            return coverView
        }
        
        func animationOptionsForAnimationCurve(curve: UInt) -> UIViewAnimationOptions {
            return UIViewAnimationOptions(rawValue: curve << 16)
        }
        
        func animation(animations: () -> Void, completion: (Bool) -> Void) {
            UIView.animateWithDuration(0.25, delay: 0, options: animationOptionsForAnimationCurve(7), animations: animations, completion: completion)
        }
        
        func executePresentAnimation(container: UIView, toView: UIView, fromView: UIView, completion: (Bool) -> Void) {
            let coverView = createCoverView(container.bounds)
            container.addSubview(coverView)
            toView.frame = container.bounds
            container.addSubview(toView)
            self.transitionCoverView = coverView
            
            preparePresentAnimation?(fromView: fromView, toView: toView)
            animation({
                coverView.alpha = 1
                self.presentAnimation?(fromView: fromView, toView: toView)
            }, completion: completion)
        }
        
        func executeDismissAnimation(container: UIView, toView: UIView, fromView: UIView, completion: (Bool) -> Void) {
            container.addSubview(fromView)
            
            prepareDismissAnimation?(fromView: fromView, toView: toView)
            animation({
                self.dismissAnimation?(fromView: fromView, toView: toView)
                self.transitionCoverView?.alpha = 0
                self.transitionCoverView = nil
            }, completion: completion)
        }
        
        // MARK: - Real logical
        guard let container = transitionContext.containerView() else {
            return transitionContext.completeTransition(false)
        }
        guard let to = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
            return transitionContext.completeTransition(false)
        }
        guard let from = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return transitionContext.completeTransition(false)
        }
        
        if presentedAnimation {
            executePresentAnimation(container, toView: to.view, fromView: from.view) { _ in
                transitionContext.completeTransition(true)
            }
        } else {
            executeDismissAnimation(container, toView: to.view, fromView: from.view) { _ in
                transitionContext.completeTransition(true)
            }
        }
    }
}
