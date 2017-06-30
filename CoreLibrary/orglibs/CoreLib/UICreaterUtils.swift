//
//  UICreaterUtils.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/11/29.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class UICreaterUtils: AnyObject {
   
    public static let normalLineWidth:CGFloat = 0.5
    public static let normalLineColor:UIColor = UIColor(red: 218/255, green: 218/255, blue: 218/255, alpha: 1)
    
    public static let colorBlack:UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
    
    public static let colorRise:UIColor = UIColor(red: 232/255, green: 55/255, blue: 59/255, alpha: 1)
    public static let colorDrop:UIColor = UIColor(red: 135/255, green: 194/255, blue: 41/255, alpha: 1)
    public static let colorFlat:UIColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
    
    public static func createLabel(size:CGFloat,_ color:UIColor,_ text:String = "",_ sizeToFit:Bool = false,_ parent:UIView? = nil)->UILabel{
        return createLabel(nil,size,color,text,sizeToFit,parent);
    }
    
    public static func createLabel(fontName:String?,_ size:CGFloat,_ color:UIColor,_ text:String = "",_ sizeToFit:Bool = false,_ parent:UIView? = nil)->UILabel{
        let uiLabel = UILabel()
        if parent != nil{
            parent?.addSubview(uiLabel)
        }
        if(fontName != nil){
            uiLabel.font = UIFont(name: fontName!, size: size)
        }else{
            uiLabel.font = UIFont.systemFontOfSize(size)//UIFont(name: "Arial Rounded MT Bold", size: size)
        }
        uiLabel.textColor = color
        uiLabel.text = text
        uiLabel.userInteractionEnabled = false //默认没有交互
        if sizeToFit{
            uiLabel.sizeToFit()
        }
        return uiLabel
    }
    
    public static func createNavigationNormalButtonItem(themeColor:UIColor,_ font:UIFont,_ text:String,_ target:AnyObject,
        _ action:Selector)->UIBarButtonItem{
            let buttonItem:UIBarButtonItem = UIBarButtonItem(title: text, style: UIBarButtonItemStyle.Plain, target: target, action: action);
            
            buttonItem.setTitleTextAttributes([NSFontAttributeName:font], forState: UIControlState.Normal);
            buttonItem.tintColor = themeColor;
            return buttonItem;
    }
    
}
