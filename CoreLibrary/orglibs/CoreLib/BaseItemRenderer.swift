
//
//  ItemRenderer.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/10/17.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class BaseItemRenderer: UIControl {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    private var _selected:Bool = false
    public override var selected:Bool{
        set(newValue){
            if _selected != newValue{
                _selected = newValue
                setNeedsLayout()
            }
        }get{
            return _selected
        }
    }
    
    private var _itemIndex:Int = 0
    public var itemIndex:Int{
        set(newValue){
            if _itemIndex != newValue{
                _itemIndex = newValue
                setNeedsLayout()
            }
        }get{
            return _itemIndex
        }
    }
    
//    private var _data:AnyObject? = nil
    public var data:Any?{
//        set(newValue){
//            _data = newValue
//            setNeedsDisplay()
//        }get{
//            return _data
//        }
        didSet{
            setNeedsLayout()
        }
    }
    
    
    
}
