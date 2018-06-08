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
import PresentAnimatedTransitioningController

public final class ActionSheetController: UIViewController {
    public fileprivate(set) var actions: [SheetAction] = []
    
    fileprivate static let fixedRowHeight: CGFloat = 50
    
    fileprivate let contentTitle: String
    fileprivate let contentTitleColor: UIColor
    
    fileprivate let cancelTitle: String
    fileprivate let cancelTitleColor: UIColor
    
    fileprivate var containerViewHeightConstraint: NSLayoutConstraint!
    fileprivate var containerViewAppearedVerticalConstraint: NSLayoutConstraint!
    fileprivate var containerViewDisAppearedVerticalConstraint: NSLayoutConstraint!
    
    fileprivate let transitioningController: PresentAnimatedTransitioningController = PresentAnimatedTransitioningController()
    
    public init(title: String = "", titleColor: UIColor = UIColor.gray, cancelTitle: String = "取消", cancelTitleColor: UIColor = UIColor.black) {
        contentTitle = title
        contentTitleColor = titleColor
        self.cancelTitle = cancelTitle
        self.cancelTitleColor = cancelTitleColor
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        transitioningDelegate = transitioningController
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate let labelBackedView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return view
    }()
    
    fileprivate let topBorderline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.gray
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.rowHeight = ActionSheetController.fixedRowHeight
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return tableView
    }()
    
    fileprivate let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        button.setBackgroundImage(UIImageFrom(color: UIColor.black.withAlphaComponent(0.2)), for: .highlighted)
        return button
    }()
    
    fileprivate let containerView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        prepareTransitioningController()
        prepareConstraints()
        setupUserInterface()
        setupConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(handleChangeStatusBarOrientation(sender:)), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    fileprivate func prepareTransitioningController() {
        transitioningController.willPresent = { [unowned self] (fromView, toView) in
            toView.layoutIfNeeded()
            toView.removeConstraint(self.containerViewDisAppearedVerticalConstraint)
            toView.addConstraint(self.containerViewAppearedVerticalConstraint)
        }
        transitioningController.inPresent = { (fromView, toView) in
            toView.layoutIfNeeded()
        }
        transitioningController.willDismiss = { [unowned self] (fromView, toView) in
            fromView.removeConstraint(self.containerViewAppearedVerticalConstraint)
            fromView.addConstraint(self.containerViewDisAppearedVerticalConstraint)
        }
        transitioningController.inDismiss = { (fromView, toView) in
            fromView.layoutIfNeeded()
        }
    }
    
    fileprivate func prepareConstraints() {
        containerViewAppearedVerticalConstraint = {
            if #available(iOS 11.0, *) {
                return containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            } else {
                return NSLayoutConstraint(
                    item: containerView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0
                )
            }
        }()
        
        containerViewDisAppearedVerticalConstraint = {
            return NSLayoutConstraint(
                item: containerView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            )
        }()
    }
    
    fileprivate func setupUserInterface() {
        titleLabel.text = contentTitle
        titleLabel.textColor = contentTitleColor
        
        cancelButton.setTitleColor(cancelTitleColor, for: UIControlState())
        cancelButton.setTitle(cancelTitle, for: UIControlState())
        cancelButton.addTarget(self, action: #selector(ActionSheetController._dismiss), for: .touchUpInside)
        
        view.addSubview(containerView)
        containerView.contentView.addSubview(cancelButton)
        containerView.contentView.addSubview(tableView)
        containerView.contentView.addSubview(labelBackedView)
        labelBackedView.contentView.addSubview(topBorderline)
        containerView.contentView.addSubview(titleLabel)

        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: ActionSheetCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    fileprivate func setupConstraints() {
        // containerView
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|[containerView]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views: ["containerView": containerView]
            )
        )
        containerViewHeightConstraint = renewConstraint()
        view.addConstraints([
            containerViewDisAppearedVerticalConstraint,
            containerViewHeightConstraint
        ])
        
        // titleLabel
        if !contentTitle.isEmpty {
            containerView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-16-[titleLabel]-16-|",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views: ["titleLabel": titleLabel]
                )
            )
            containerView.addConstraints([
                NSLayoutConstraint(
                    item: titleLabel,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: containerView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 20
                ),
                NSLayoutConstraint(
                    item: tableView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: titleLabel,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 20
                )
            ])
            
            // labelBackedView
            containerView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-0-[labelBackedView]-0-|",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views: ["labelBackedView": labelBackedView]
                )
            )
            containerView.addConstraints([
                NSLayoutConstraint(
                    item: labelBackedView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: containerView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0
                ),
                NSLayoutConstraint(
                    item: labelBackedView,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: tableView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0
                )
            ])
            
            // topBorderline
            labelBackedView.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "|-0-[topBorderline]-0-|",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views: ["topBorderline": topBorderline]
                )
            )
            labelBackedView.addConstraints([
                NSLayoutConstraint(
                    item: topBorderline,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1,
                    constant: 1.0 / UIScreen.main.scale
                ),
                NSLayoutConstraint(
                    item: topBorderline,
                    attribute: .bottom,
                    relatedBy: .equal,
                    toItem: labelBackedView,
                    attribute: .bottom,
                    multiplier: 1,
                    constant: 0
                )
            ])
        } else {
            containerView.addConstraints([
                NSLayoutConstraint(
                    item: tableView,
                    attribute: .top,
                    relatedBy: .equal,
                    toItem: containerView,
                    attribute: .top,
                    multiplier: 1,
                    constant: 0
                )
            ])
        }

        // tableView
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|[tableView]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views: ["tableView": tableView]
            )
        )
        containerView.addConstraints([
            NSLayoutConstraint(
                item: tableView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: cancelButton,
                attribute: .top,
                multiplier: 1,
                constant: -6
            )
        ])
        
        // cancelButton
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|[cancelButton]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views: ["cancelButton": cancelButton]
            )
        )
        containerView.addConstraints([
            NSLayoutConstraint(
                item: cancelButton,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: containerView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0
            ),
            NSLayoutConstraint(
                item: cancelButton,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 0,
                constant: ActionSheetController.fixedRowHeight
            )
        ])
    }
    
    public override func updateViewConstraints() {
        view.removeConstraints([containerViewHeightConstraint])
        containerViewHeightConstraint = renewConstraint()
        view.addConstraint(containerViewHeightConstraint)
        super.updateViewConstraints()
    }
    
    @objc func handleChangeStatusBarOrientation(sender: Notification) {
        updateViewConstraints()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        dismissWithCompletion(nil)
    }
    
    internal func dismissWithCompletion(_ completion: (() -> Void)?) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }
    
    @objc internal func _dismiss() {
        dismissWithCompletion(nil)
    }
    
    public func addAction(_ action: SheetAction) {
        actions.append(action)
    }
    
    // MARK: - UI
    
    fileprivate func renewConstraint() -> NSLayoutConstraint {
        func containerViewHeight() -> CGFloat {
            // 计算文本高度
            var textHeight: CGFloat = 0
            if !contentTitle.isEmpty {
                textHeight = 40
                let width = view.bounds.width - 32
                let boundingRect = (contentTitle as NSString).boundingRect(
                    with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine],
                    attributes: [NSAttributedStringKey.font: titleLabel.font],
                    context: nil
                )
                textHeight += boundingRect.size.height
            }
            let height = CGFloat(actions.count) * ActionSheetController.fixedRowHeight + textHeight
            let maxHeight = view.bounds.height * CGFloat(0.67)
            if height > maxHeight {
                return maxHeight + ActionSheetController.fixedRowHeight + 36
            }
            return height + ActionSheetController.fixedRowHeight + 6
        }
        
        return NSLayoutConstraint(
            item: containerView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: containerViewHeight()
        )
    }
}

// MARK: - Table view methods

extension ActionSheetController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActionSheetCell.identifier, for: indexPath) as? ActionSheetCell  else {
            fatalError("dequeue cell failure.")
        }
        
        cell.setupData(actions[(indexPath as NSIndexPath).row])
        
        return cell
    }
}

extension ActionSheetController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let action = actions[(indexPath as NSIndexPath).row]
        dismissWithCompletion { () -> Void in
            action.handler?(action)
        }
    }
}

// MARK: - ActionSheetCell

private final class ActionSheetCell: UITableViewCell {
    fileprivate static var identifier: String {
        return NSStringFromClass(self)
    }
    
    fileprivate let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        label.textAlignment = .center
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
    
    fileprivate func setupUserInterface() {
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            return view
        }()
        
        contentView.addSubview(contentLabel)
        
        let views = ["label": contentLabel]
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-8-[label]-8-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views: views
            )
        )
        contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[label]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views: views
            )
        )
    }
    
    fileprivate func setupData(_ action: SheetAction) {
        contentLabel.text = action.title
        contentLabel.textColor = action.titleColor
    }
}


// MARK: -  Utils

public func UIColorFrom(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 100) -> UIColor {
    return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha / 100)
}

private func UIImageFrom(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
    UIGraphicsBeginImageContext(size)
    guard let context = UIGraphicsGetCurrentContext() else {
        return nil
    }
    context.setFillColor(color.cgColor)
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    context.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image!
}
