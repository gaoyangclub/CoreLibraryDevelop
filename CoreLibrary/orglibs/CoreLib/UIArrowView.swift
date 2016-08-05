//
//  UIArrowView.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/11/2.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

//控件的刷新状态
public enum ArrowDirect {
    case  LEFT
    case  RIGHT
    case  UP
    case  DOWN
}
public class UIArrowView: UIControl {

    
    public override init(frame: CGRect) {
        super.init(frame:frame);
        self.backgroundColor = UIColor.clearColor()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //绘制三角形实体
    public override func drawRect(rect: CGRect) {
        let linePath = UIBezierPath()
        linePath.lineWidth = lineThinkness
        linePath.lineCapStyle = CGLineCap.Round//笔触为圆形
        if direction == ArrowDirect.LEFT{
            linePath.moveToPoint(CGPoint(x: rect.width - lineThinkness / 2, y: lineThinkness / 2))
            linePath.addLineToPoint(CGPoint(x: lineThinkness / 2,y: rect.height / 2))
            linePath.addLineToPoint(CGPoint(x: rect.width - lineThinkness / 2, y: rect.height - lineThinkness / 2))
        }else if direction == ArrowDirect.RIGHT{
            linePath.moveToPoint(CGPoint(x: lineThinkness / 2, y: lineThinkness / 2))
            linePath.addLineToPoint(CGPoint(x: rect.width - lineThinkness / 2,y: rect.height / 2))
            linePath.addLineToPoint(CGPoint(x: lineThinkness / 2, y: rect.height - lineThinkness / 2))
        }else if direction == ArrowDirect.UP{
            linePath.moveToPoint(CGPoint(x: lineThinkness / 2, y: rect.height - lineThinkness / 2))
            linePath.addLineToPoint(CGPoint(x: rect.width / 2, y: lineThinkness / 2))
            linePath.addLineToPoint(CGPoint(x: rect.width - lineThinkness / 2, y: rect.height - lineThinkness / 2))
        }else if direction == ArrowDirect.DOWN{
            linePath.moveToPoint(CGPoint(x: lineThinkness / 2, y: lineThinkness / 2))
            linePath.addLineToPoint(CGPoint(x: rect.width / 2, y: rect.height - lineThinkness / 2))
            linePath.addLineToPoint(CGPoint(x: rect.width - lineThinkness / 2, y: lineThinkness / 2))
        }
        
        if(isClosed){
            linePath.closePath() //封闭图形
        }
        lineColor.setStroke()
        linePath.stroke() //绘制线条
        
        let fillAlpha = CGColorGetAlpha(fillColor.CGColor)
        if fillAlpha != 0 {
            let fillPath = linePath.copy() as! UIBezierPath
            fillPath.closePath() //封闭图形

            fillColor.setFill()
            fillPath.fill()
        }
    }
    
    public var direction:ArrowDirect = .LEFT{//默认向左
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var lineColor:UIColor = UIColor.blackColor(){//线条色
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var lineThinkness:CGFloat = 1{//线条粗细
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var fillColor:UIColor = UIColor.clearColor(){//填充
        didSet{
            setNeedsDisplay()
        }
    }
    
    public var isClosed:Bool = false{//是否封闭三角形
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    
    
    
}
