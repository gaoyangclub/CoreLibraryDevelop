//
//  UIFlatImageTabItem.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/12/6.
//  Copyright (c) 2015年 高扬. All rights reserved.
//  触发离屏渲染的罪魁祸首 用iconfont代替
//

import UIKit

public enum SizeType{
    case Tight //严格按照宽高
    case FillWidth //宽度自动衡量
    case FillHeight //高度自动衡量
}
public class UIFlatImageTabItem: UIControl {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    public required init(){
        super.init(frame: CGRectZero)
    }
    
    public init(image:UIImage){
        super.init(frame: CGRectZero)
        self.image = image
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var sizeType:SizeType = .Tight{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var image:UIImage!{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var normalColor:UIColor = UIColor.grayColor(){
        didSet{
            setNeedsLayout()
        }
    }
    
    public var selectColor:UIColor = UIColor.brownColor(){
        didSet{
            setNeedsLayout()
        }
    }
    
    public var select:Bool = false{
        didSet{
            self.selected = select
            setNeedsLayout()
        }
    }
    
    lazy private var imageShape:CAShapeLayer = {
        let shape:CAShapeLayer = CAShapeLayer()
        self.layer.addSublayer(shape)
        return shape
    }()
    
    lazy private var imageMask:CALayer = {
        let mask = CALayer()
        self.imageShape.mask = mask
        return mask
    }()
    
    public override func layoutSubviews() {
        if image == nil{
            return
        }
        measure()
        initContain()
    }
    
    private func initContain(){
        let offsetX = (self.bounds.width - containSize.width) / 2
        let offsetY = (self.bounds.height - containSize.height) / 2
        
        let imageFrame = CGRectMake(offsetX, offsetY, containSize.width, containSize.height)
        let imgCenterPoint = CGPointMake(CGRectGetMidX(imageFrame), CGRectGetMidY(imageFrame))
        let color:UIColor = selected ? selectColor : normalColor
        
        imageShape.bounds = imageFrame
        
        imageShape.position = imgCenterPoint
        imageShape.path = UIBezierPath(rect: imageFrame).CGPath
        imageShape.fillColor = color.CGColor
        
        imageMask.contents = image.CGImage
        imageMask.bounds = imageFrame
        imageMask.position = imgCenterPoint
    }
    
    private var containSize:CGSize = CGSize()
    private func measure(){
//        if image == nil{
//            return
//        }
        switch(sizeType){
            case .FillWidth:
                containSize.height = frame.height
                containSize.width = frame.height / image.size.height * image.size.width
            case .FillHeight:
                containSize.width = frame.width
                containSize.height = frame.width / image.size.width * image.size.height
            case .Tight:
                containSize.height = frame.height
                containSize.width = frame.width
        }
        sizeToFit()
    }
    

}
