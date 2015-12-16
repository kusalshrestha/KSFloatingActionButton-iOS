//
//  FloatButton.swift
//  FloatButton
//
//  Created by Kusal Shrestha on 12/10/15.
//  Copyright © 2015 Kusal Shrestha. All rights reserved.
//

import UIKit

protocol FloatButtonDelegate: NSObjectProtocol {
    func menuTable(menuTable: UITableView, didSelectItemAtIndex index: Int)
}

class FloatButton: NSObject {

    static let buttonSize = CGSize(width: 50, height: 50)
    
    var parentView: UIView!
    var floatButton: UIButton!
    let cellHeight: CGFloat = 60
    var buttonImageView: UIImageView!
    var menuTable: UITableView!
    var blurView: UIView!
    var items: [String] = []
    var menuViewTopConstraint: [NSLayoutConstraint]! = []
    
    var rowNumber: Int = 0
    var maxCell = Int((UIScreen.mainScreen().bounds.height - 84) / FloatButton.buttonSize.height - 1)
    weak var delegate: FloatButtonDelegate!
    var cellFlag = true         // Flag for stoping animation during scroll
    
    var isMenuVisible: Bool = false {
        didSet {
            toggleMenu(buttonState: !oldValue)
            layoutViewsWithButtonState(oldValue)
        }
    }
    
    init(addFloatButtonOverView view: UIView) {
        super.init()
        
        parentView = view
        setUpMenuTable()
        setUpButton()
        isMenuVisible = false
        blurView.alpha = 0
        installConstraintsForFloatButton()
        installConstraintsForBlurView()
        installConstraintsForMenuView()
    }
    
    func buttonAction() {
        isMenuVisible = !isMenuVisible
    }
    
    func setUpButton() {
        floatButton = UIButton(frame: CGRect(origin: CGPoint(x: CGRectGetMaxX(parentView.frame) - 66, y: CGRectGetMaxY(parentView.frame) - 66), size: FloatButton.buttonSize))
        floatButton.addTarget(self, action: "buttonAction", forControlEvents: .TouchUpInside)
        floatButton.layer.cornerRadius = floatButton.frame.size.width / 2
        floatButton.layer.shadowColor = UIColor.blackColor().CGColor
        floatButton.layer.shadowRadius = 50
        floatButton.backgroundColor = UIColor.purpleColor()

        floatButton.userInteractionEnabled = true
        
        buttonImageView = UIImageView(image: UIImage(named: "plus.png"))
        buttonImageView.backgroundColor = UIColor.clearColor()
        buttonImageView.frame = floatButton.bounds
        
        floatButton.addSubview(buttonImageView)
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurView = UIView(frame: floatButton.frame)
        blurView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        blurView.userInteractionEnabled = true
        
        visualEffectView.frame = blurView.frame
        blurView = visualEffectView
        
        blurView.addSubview(menuTable)
        parentView.addSubview(blurView)
        parentView.addSubview(floatButton)
    }
    
    func layoutViewDuringOrientation() {
        menuTable.scrollEnabled = true
        maxCell = Int((UIScreen.mainScreen().bounds.height - 84) / FloatButton.buttonSize.height - 1)
        if items.count <= maxCell {
            menuTable.scrollEnabled = false
        }
        menuViewTopConstraint.first?.constant = UIScreen.mainScreen().bounds.height - 66 - CGFloat(maxCell * 60)
        print(menuViewTopConstraint)
    }
    
    func setUpMenuTable() {
        menuTable = UITableView(frame: CGRectZero)
        menuTable.registerClass(MenuCell.self, forCellReuseIdentifier: "menuCell")
        menuTable.delegate = self
        menuTable.dataSource = self
        menuTable.separatorStyle = .None
        menuTable.backgroundColor = UIColor.clearColor()
        menuTable.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI))
        menuTable.pagingEnabled = true
        menuTable.bounces = false
        menuTable.showsVerticalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutViewsWithButtonState(state: Bool) {
        var opacityValue: CGFloat = 0
        if !state {
//            print("open")
            blurView.frame = parentView.frame
            opacityValue = 1
            showMenu(nil)
        } else {
//            print("close")
            opacityValue = 0
            dismissMenu(nil)
        }
        
        UIView.animateWithDuration(0.3, animations: { _ in
            self.blurView.alpha = opacityValue
            }) { (completed) -> Void in
                if state {
                    self.blurView.frame = self.floatButton.frame
                }
        }
    }

    private func installConstraintsForFloatButton() {
        let views = ["floatButton": floatButton]
        floatButton.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[floatButton(50)]-16-|", options: [], metrics: nil, views: views))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[floatButton(50)]-16-|", options: [], metrics: nil, views: views))
    }
    
    private func installConstraintsForBlurView() {
        let views = ["blurView": blurView]
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[blurView]-0-|", options: [], metrics: nil, views: views))
        parentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[blurView]-0-|", options: [], metrics: nil, views: views))
    }
    
    private func installConstraintsForMenuView() {
        let views = ["menuTable": menuTable]
        menuTable.translatesAutoresizingMaskIntoConstraints = false
        
        blurView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[menuTable]-0-|", options: [], metrics: nil, views: views))
        menuViewTopConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[menuTable]-\(CGRectGetHeight(floatButton.frame) + 16)-|", options: [], metrics: nil, views: views)
        blurView.addConstraints(menuViewTopConstraint)
    }
    
    func toggleMenu(buttonState state: Bool) {
        rotateFloatButton(buttonState: state)
        rippleAnimation(floatButton.layer, rippleRadius: floatButton.layer.bounds.width / 2)
    }
    
    private func rotateFloatButton(buttonState state: Bool) {
        let rotation = state ? CGFloat(M_PI_4 * 3): 0
        UIView.animateWithDuration(0.3, animations: { _ in
            self.buttonImageView.transform = CGAffineTransformMakeRotation(rotation)
            }) { (completed) -> Void in
        }
    }
    
    private func rippleAnimation(layer: CALayer, rippleRadius radius: CGFloat) {
        let sizeWidth: CGFloat = radius * 2
        let rippleLayer = CALayer()
        rippleLayer.frame = CGRect(origin: CGPointZero, size: CGSizeMake(sizeWidth, sizeWidth))
        rippleLayer.position = CGPoint(x: CGRectGetMidX(layer.bounds), y: CGRectGetMidY(layer.bounds))
        rippleLayer.cornerRadius = radius
        rippleLayer.backgroundColor = UIColor.grayColor().CGColor
        layer.addSublayer(rippleLayer)
        
        let rippleAnimation = CABasicAnimation(keyPath: "transform.scale")
        rippleAnimation.fromValue = 0.8
        rippleAnimation.toValue = 1.3
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.8
        opacityAnimation.toValue = 0
        
        CATransaction.begin()
        let groupAnimation = CAAnimationGroup()
        groupAnimation.animations = [rippleAnimation, opacityAnimation]
        groupAnimation.duration = 0.2
        groupAnimation.delegate = self
        groupAnimation.removedOnCompletion = true
        groupAnimation.setValue(rippleLayer, forKey: "ripple")
        
        CATransaction.setCompletionBlock { () -> Void in
            rippleLayer.removeFromSuperlayer()
        }
        
        rippleLayer.addAnimation(groupAnimation, forKey: "key")
        CATransaction.commit()
    }

    private func showMenu(sender: AnyObject?) {
        rowNumber = items.count
        cellFlag = !cellFlag
        menuTable.reloadData()
    }
    
    private func dismissMenu(sender: AnyObject?) {
        rowNumber = 0
        menuTable.reloadData()
    }

}

extension FloatButton: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowNumber
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuCell
        cell.bgView.image = UIImage(named: items[indexPath.row])
        return cell
    }
    
}

extension FloatButton: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.row < maxCell else {
            return
        }
        if !cellFlag {
            var delay = 0.125 * Double(indexPath.row)

            if indexPath.row > 0 {
                cell.hidden = true
            } else {
                delay = 0
            }
            let originalPosition = cell.center.y
            cell.center.y = cell.center.y - cellHeight
            UIView.animateKeyframesWithDuration(0.15, delay: delay, options: [], animations: { _ in
                cell.center.y = originalPosition
                }) { (completed) -> Void in
                    if indexPath.row < self.rowNumber {
                        
                        let indxPath = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
                        let cel = tableView.cellForRowAtIndexPath(indxPath)
                        cel?.hidden = false
                }
            }
            if indexPath.row == maxCell - 1 {
                cellFlag = true // stop animation when scrolled
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate.menuTable(tableView, didSelectItemAtIndex: indexPath.row)
    }
    
}

extension CATransaction {
    
    class func animateWithDuration(duration: CFTimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, animations: () -> Void, completionBlock: (() -> Void)? = nil) {
        begin()
        setAnimationDuration(duration)
        setCompletionBlock(completionBlock)
        setAnimationTimingFunction(timingFunction)
        animations()
        commit()
    }
    
}

