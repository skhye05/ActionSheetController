//
//  ActionSheetController.swift
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

public final class ActionSheetController: UIViewController {
    private let fixedRowHeight: CGFloat = 50
    private let cancelTitle: String
    private let cancelTitleColor: UIColor
    public private(set) var actions: [SheetAction] = []
    
    private var containerViewHeightConstraint: NSLayoutConstraint!
    
    private lazy var containerViewAppearedVerticalConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: self.containerView,
            attribute: .Bottom,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0
        )
    }()
    
    private lazy var containerViewDisAppearedVerticalConstraint: NSLayoutConstraint = {
        return NSLayoutConstraint(
            item: self.containerView,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self.view,
            attribute: .Bottom,
            multiplier: 1,
            constant: 0
        )
    }()
    
    lazy var animation: PresentTranslucentAnimation = {
        return PresentTranslucentAnimation(preparePresentAnimation: { [unowned self] _ in
                self.view.layoutIfNeeded()
                self.view.removeConstraint(self.containerViewDisAppearedVerticalConstraint)
                self.view.addConstraint(self.containerViewAppearedVerticalConstraint)
            }, presentAnimation: { [unowned self] _ in
                self.view.layoutIfNeeded()
            }, prepareDismissAnimation: { [unowned self] _ in
                self.view.removeConstraint(self.containerViewAppearedVerticalConstraint)
                self.view.addConstraint(self.containerViewDisAppearedVerticalConstraint)
            }, dismissAnimation: { [unowned self] _ in
                self.view.layoutIfNeeded()
        })
    }()
    
    public init(cancelTitle: String = "取消", cancelTitleColor: UIColor = UIColor.blackColor()) {
        self.cancelTitle = cancelTitle
        self.cancelTitleColor = cancelTitleColor
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
        transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.rowHeight = self.fixedRowHeight
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, 0, CGFloat.min))
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        
        tableView.registerClass(ActionSheetCell.self, forCellReuseIdentifier: ActionSheetCell.identifier)
        
        return tableView
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        button.setTitleColor(self.cancelTitleColor, forState: .Normal)
        button.setBackgroundImage(UIImageFromColor(UIColor.blackColor().colorWithAlphaComponent(0.1)), forState: .Highlighted)
        button.setTitle(self.cancelTitle, forState: .Normal)
        return button
    }()
    
    lazy var containerView: UIView = {
        let view = makeBlurView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupUserInterface()
        setupConstraints()
    }
    
    public override func updateViewConstraints() {
        view.removeConstraints([containerViewHeightConstraint])
        containerViewHeightConstraint = renewConstraint()
        view.addConstraint(containerViewHeightConstraint)
        
        super.updateViewConstraints()
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)

        dismissWithCompletion(nil)
    }
    
    internal func dismissWithCompletion(completion: (() -> Void)?) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: completion)
    }
    
    internal func dismiss() {
        dismissWithCompletion(nil)
    }
}

public extension ActionSheetController {
    public func addAction(action: SheetAction) {
        actions.append(action)
    }
}

private extension ActionSheetController {
    private func renewConstraint() -> NSLayoutConstraint {
        func containerViewHeight() -> CGFloat {
            let height = CGFloat(actions.count) * fixedRowHeight
            let maxHeight = CGRectGetHeight(view.bounds) * CGFloat(0.67)
            
            return (height > maxHeight ? maxHeight : height) + fixedRowHeight + 5
        }
        
        return NSLayoutConstraint(
            item: containerView,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Height,
            multiplier: 0,
            constant: containerViewHeight()
        )
    }
    
    private func setupUserInterface() {
        tableView.delegate = self
        tableView.dataSource = self
        
        cancelButton.addTarget(self, action: #selector(ActionSheetController.dismiss), forControlEvents: .TouchUpInside)
        
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        containerView.addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|[containerView]|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: ["containerView": containerView]
            )
        )
        containerViewHeightConstraint = renewConstraint()
        view.addConstraints([
            containerViewDisAppearedVerticalConstraint,
            containerViewHeightConstraint
        ])
        
        containerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|[tableView]|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: ["tableView": tableView]
            )
        )
        containerView.addConstraints([
            NSLayoutConstraint(
                item: tableView,
                attribute: .Top,
                relatedBy: .Equal,
                toItem: containerView,
                attribute: .Top,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: tableView,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: cancelButton,
                attribute: .Top,
                multiplier: 1,
                constant: -5
            )
        ])
        
        containerView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|[cancelButton]|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: ["cancelButton": cancelButton]
            )
        )
        containerView.addConstraints([
            NSLayoutConstraint(
                item: cancelButton,
                attribute: .Bottom,
                relatedBy: .Equal,
                toItem: containerView,
                attribute: .Bottom,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: cancelButton,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: containerView,
                attribute: .Height,
                multiplier: 0,
                constant: fixedRowHeight
            )
        ])
    }
}


// MARK: - Table view methods

extension ActionSheetController: UITableViewDataSource {
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier(ActionSheetCell.identifier, forIndexPath: indexPath) as? ActionSheetCell  else {
            fatalError("dequeue cell failure.")
        }
        
        cell.setupData(actions[indexPath.row])
        
        return cell
    }
}

extension ActionSheetController: UITableViewDelegate {
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let action = actions[indexPath.row]
        dismissWithCompletion { () -> Void in
            action.handler?(action)
        }
    }
}

// MARK: - Animation

extension ActionSheetController: UIViewControllerTransitioningDelegate {
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animation.prepareForPresent()
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animation.prepareForDismiss()
    }
}

// MARK: - ActionSheetCell

private final class ActionSheetCell: UITableViewCell {
    private static var identifier: String {
        return NSStringFromClass(self)
    }
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.blackColor()
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        label.textAlignment = .Center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUserInterface()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUserInterface() {
        layoutMargins = UIEdgeInsetsZero
        separatorInset = UIEdgeInsetsZero
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.1)
            return view
        }()
        
        
        contentView.addSubview(contentLabel)
        
        let views = ["label": contentLabel]
        contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "|-8-[label]-8-|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: views
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[label]|",
                options: NSLayoutFormatOptions.DirectionLeadingToTrailing,
                metrics: nil,
                views: views
            )
        )
    }
    
    private func setupData(action: SheetAction) {
        contentLabel.text = action.title
        contentLabel.textColor = action.titleColor
    }
}


// MARK: -  Utils

private func UIColorFromRed(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 100) -> UIColor {
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha / 100)
}

private func UIImageFromColor(color: UIColor, size: CGSize = CGSizeMake(1, 1)) -> UIImage {
    UIGraphicsBeginImageContext(size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, color.CGColor)
    let rect = CGRectMake(0, 0, size.width, size.height)
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

private func makeBlurView() -> UIView {
    if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
        return UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    } else {
        let visualView = UIToolbar(frame: CGRectZero)
        visualView.barStyle = .Default
        visualView.translucent = true
        return visualView
    }
}