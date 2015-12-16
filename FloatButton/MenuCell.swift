//
//  MenuView.swift
//  FloatingAction
//
//  Created by Kusal Shrestha on 12/9/15.
//  Copyright © 2015 Kusal Shrestha. All rights reserved.
//

import UIKit
import QuartzCore

class MenuCell: UITableViewCell {
    
    var bgView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        backgroundColor = UIColor.clearColor()
        contentView.backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        
        bgView = UIImageView(frame: CGRectZero)
        bgView.backgroundColor = UIColor.grayColor()
                addSubview(bgView)
        
    }
    
    override func drawRect(rect: CGRect) {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let rect = frame
        let height = FloatButton.buttonSize.height
        bgView.frame = CGRect(x: CGRectGetMaxX(rect) - height - 16, y: 0, width: height, height: height)
        let layer = bgView.layer
        layer.cornerRadius = bgView.frame.size.width / 2
        bgView.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
