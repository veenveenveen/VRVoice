//
//  CornerRectView.swift
//  VRClient
//
//  Created by 黄启明 on 2017/5/3.
//  Copyright © 2017年 黄启明. All rights reserved.
//

import UIKit

@IBDesignable

class CornerRectView: UIView {
    
    //填充色
    @IBInspectable var fillColor: UIColor = UIColor.white

    //圆角半径
    @IBInspectable var cornerRadius: CGFloat = 10
    
    //阴影
    @IBInspectable var isShadowEnabled: Bool = true
    @IBInspectable var shadowColor: UIColor = UIColor.darkGray
    @IBInspectable var shadowRadius: CGFloat = 10
    @IBInspectable var shadowOpacity: Float = 0.4
    @IBInspectable var shadowOffsetX: CGFloat = 0
    @IBInspectable var shadowOffsetY: CGFloat = -2
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupCorner()
        setupShadow()
    }
    
    //设置圆角
    fileprivate func setupCorner() {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        let roundRectLayer = CAShapeLayer()
        roundRectLayer.path = path.cgPath
        roundRectLayer.frame = bounds
        roundRectLayer.fillColor = fillColor.cgColor
        layer.insertSublayer(roundRectLayer, at: 0)
        
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//        context.beginPath()
//        context.addPath(path.cgPath)
//        context.setFillColor(fillColor.cgColor)
//        context.fillPath()
//        context.strokePath()
        
//        print(frame.size.height)
    }

    //设置阴影
    fileprivate func setupShadow() {
        if isShadowEnabled {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = shadowOpacity
            layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
        }
    }
}
