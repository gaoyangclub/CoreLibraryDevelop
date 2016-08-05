//
//  RoundTagView.swift
//  BestPalmPilot
//
//  Created by admin on 16/1/19.
//  Copyright © 2016年 admin. All rights reserved.
//

import UIKit

public class RoundTagView:UIView{
    
    public var tagSize:CGFloat = 10{
        didSet{
            setNeedsLayout()
        }
    }
    public var tagColor:UIColor = UIColor.grayColor(){
        didSet{
            setNeedsLayout()
        }
    }
    
    public var tagText:String = ""{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var backColor:UIColor = UIColor.blackColor(){
        didSet{
            setNeedsLayout()
        }
    }
    
    public var showBorder:Bool = true{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var borderWidth:CGFloat = 0.6{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var cornerRadius:CGFloat = 3{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var showBack:Bool = false{
        didSet{
            setNeedsLayout()
        }
    }
    
    //    private lazy var tagLabel:UILabel = {
    //       let labal = UICreaterUtils.createLabel(10, UIColor.grayColor(), "")
    //        return labal
    //    }()
    private var tagLabel:UILabel!
    //    private var subView:UIView!
    
    public override func layoutSubviews() {
        initView()
    }
    
    public var minTagWidth:CGFloat = 20{
        didSet{
            setNeedsLayout()
        }
    }
    public var minTagHeight:CGFloat = 10{
        didSet{
            setNeedsLayout()
        }
    }
    
    private func initView(){
        if tagLabel == nil{
            tagLabel = UICreaterUtils.createLabel(tagSize, tagColor, "",true,self)
            tagLabel.textAlignment = NSTextAlignment.Center
            //            subView = UIView()
            //            addSubview(subView)
            
            tagLabel.snp_makeConstraints { [weak self](make) -> Void in
//                make.left.top.equalTo(self!)
                make.center.equalTo(self!)
            }
            
            if showBorder {
                self.layer.borderColor = tagColor.CGColor
                self.layer.borderWidth = borderWidth
            }else{
                self.layer.borderWidth = 0
            }
            if showBack{
                self.backgroundColor = self.backColor
            }else{
                self.backgroundColor = UIColor.clearColor()
            }
            self.layer.cornerRadius = cornerRadius
            self.snp_makeConstraints { [weak self](make) -> Void in
                make.width.greaterThanOrEqualTo(self!.minTagWidth)
                make.width.equalTo(self!.tagLabel).offset(6)
                make.height.greaterThanOrEqualTo(self!.minTagHeight)
                make.height.equalTo(self!.tagLabel).offset(2)
            }
        }
//        tagLabel.backgroundColor = UIColor.blueColor()
        tagLabel.text = tagText
        tagLabel.font = UIFont.systemFontOfSize(tagSize)
        tagLabel.textColor = tagColor
        tagLabel.sizeToFit()
    }
}
