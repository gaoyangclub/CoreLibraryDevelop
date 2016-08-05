//
//  UIColumnChart.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/12/3.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public enum ChartType{
    case Column //柱形图
    case Line //线形图
}
public enum DateType{
    case Normal //按Date算
    case Hour //一天从9：30-11：30/13：00-15:00
}
//控件的刷新状态
public enum CompareType {
    case First               // 和第一个值比
    case Previous                // 和前一个值比
    case Regular            // 和固定值比
}
public class UIColumnChart: UIView {
   
    public var chartType:ChartType = .Column{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var dateType:DateType = .Normal{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var compareType:CompareType = .Previous{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var compareRegularValue:CGFloat = 1{
        didSet{
            setNeedsLayout()
        }
    }
    
    public weak var delegate:TrendChartDelegate?
    
    /** 横向日期数组 */
    public var dateList:[NSDate]!{
        didSet{
            setNeedsLayout()
        }
    }
    /** 纵向数据二维数组 */
    public var chartDataList:[CGFloat]!{
        didSet{
            setNeedsLayout()
        }
    }
    /** 数据集对应颜色 */
    public var lineColor:UIColor = UICreaterUtils.colorRise{
        didSet{
            setNeedsLayout()
        }
    }
    /** 数据集对应线条宽度 */
    public var lineWidth:CGFloat = 1{
        didSet{
            setNeedsLayout()
        }
    }
    /** 横向分段数 */
    public var segments:Int = 4{
        didSet{
            setNeedsLayout()
        }
    }
    /** 日期间隔时间段 */
    public var timeGap:Double = 3600{
        didSet{
            setNeedsLayout()
        }
    }
    /** 增长偏移值 */
    public var offsetRateValue:Float = 10{
        didSet{
            setNeedsLayout()
        }
    }
    /** 日期行文字占用高度 */
    public var dateAreaHeight:CGFloat = 12{
        didSet{
            setNeedsLayout()
        }
    }
    public var zeroValueTag:CGFloat = 1 //0替换的值
    
    public override func layoutSubviews() {
        backgroundColor = UIColor.clearColor()
        
        if chartDataList == nil || chartDataList.count == 0{
            return //没有一组数据
        }
        measure()
        initChartLabel()
        initGestureRecognizer()
        setNeedsDisplay()
    }
    
    private var gestrueArea:UIView!
    private var panGestrue:UIPanGestureRecognizer!
    private var tapGestrue:UITapGestureRecognizer!
    /** 添加按下松开和拖动手势 */
    private func initGestureRecognizer(){
        if panGestrue == nil{
            panGestrue = UIPanGestureRecognizer(target: self, action: "panHandler:")
            chartLabelView.addGestureRecognizer(panGestrue)
            panGestrue.minimumNumberOfTouches = 1
            panGestrue.maximumNumberOfTouches = 1
            //            panGestrue.delegate = self
        }
        if tapGestrue == nil{
            tapGestrue = UITapGestureRecognizer(target: self, action: "tapHandler:")
            chartLabelView.addGestureRecognizer(tapGestrue)
            tapGestrue.numberOfTapsRequired = 1
        }
    }
    
    
    private var prevTouchPoint:CGPoint!
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count > 0{
            let nowTouch = touches[touches.startIndex] as UITouch
            let nowPoint = nowTouch.locationInView(self)
            
            let dirtX = abs(nowPoint.x - prevTouchPoint.x)
            let dirtY = abs(nowPoint.y - prevTouchPoint.y)
            if  dirtX > dirtY {//横向移动
                panGestrue.enabled = true
            }else{
                panGestrue.enabled = false
            }
        }
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.count > 0{
            let prevTouch = touches[touches.startIndex] as UITouch
            prevTouchPoint = prevTouch.locationInView(self)
        }
    }
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        resumePan()
    }
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resumePan()
    }
    
    func tapHandler(sender:UIGestureRecognizer){
        if sender.numberOfTouches() > 0{
            measureGestruePoint(sender)
        }
    }
    
    private func measureGestruePoint(sender:UIGestureRecognizer){
        let nowPoint:CGPoint = sender.locationOfTouch(0, inView: self)
        showGestrueLine(getGestureIndex(nowPoint.x))
    }
    
    //    private var prevTouchPoint:CGPoint?
    func panHandler(sender:UIGestureRecognizer){
        if sender.state == .Ended{
            hideGestrueLine()
        }else if sender.numberOfTouches() > 0{
            measureGestruePoint(sender)
        }
    }
    
    private func showGestrueLine(index:Int){
        let viewWidth:CGFloat = self.frame.width
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - dateAreaHeight
        
        gestrueArea.removeAllSubViews()
        
        let lineV:UIView = UIView(frame: CGRectMake(getSourceLineX(index), 0, 1, chartHeight))
        lineV.backgroundColor = UICreaterUtils.colorFlat
        gestrueArea.addSubview(lineV)
        
        let compareValue = getCompareValue(index)
        let value = chartDataList[index]
        let lineH:UIView = UIView(frame: CGRectMake(0,getSourceLineY(value,compareValue: compareValue),viewWidth, 1))
        lineH.backgroundColor = UICreaterUtils.colorFlat
        gestrueArea.addSubview(lineH)
        
        delegate?.touchChartLineBegin?(index)//某条交互记录开始
    }
    
    private func hideGestrueLine(){
        gestrueArea.removeAllSubViews()
        delegate?.touchChartLineEnd?()//交互结束
        
        resumePan()
    }
    
    private func resumePan(){
        if (panGestrue != nil){
            panGestrue.enabled = true
        }
        prevTouchPoint = nil
    }

    private func initChartLabel(){
        if chartLabelView == nil{
            chartLabelView = UIView()
            self.addSubview(chartLabelView)
            chartLabelView.snp_makeConstraints(closure: { [weak self](make) -> Void in
                make.left.right.top.bottom.equalTo(self!)
            })
        }
        chartLabelView.removeAllSubViews()
        if gestrueArea == nil{
            gestrueArea = UIView()
            self.addSubview(gestrueArea)
            gestrueArea.userInteractionEnabled = false
            gestrueArea.snp_makeConstraints(closure: { [weak self](make) -> Void in
                make.left.right.top.bottom.equalTo(self!.chartLabelView)
            })
        }
        hideGestrueLine()
    }
    
    private var minChartY:CGFloat!
    private var maxChartY:CGFloat!
    private var zeroChartY:CGFloat!
    
    private var divideEqually:Bool!
    private var segmentArea:[Int]!
    
//    private var bottomView:UIView!
    private var chartLabelView:UIView!
    
    //测量坐标系 获取0点位置坐标 获取横向间距
    private func measure(){
        var minValue:CGFloat = 0
        var maxValue:CGFloat = 0
        for i in 0..<chartDataList.count{
            let value = chartDataList[i]
            let compareValue:CGFloat = getCompareValue(i)
            let rateValue = (value / compareValue - 1) * 100
            if rateValue < minValue{
                minValue = rateValue
            }else if rateValue > maxValue{
                maxValue = rateValue
            }
        }
        var po:Float = Float(maxValue)
        var ne:Float = Float(minValue)
        po *= (1 + offsetRateValue / 100)
        ne *= (1 + offsetRateValue / 100)
        let positiveValue = Int(abs(ceil(po)))
        let negativeValue = Int(abs(ceil(ne)))
        
        segmentArea = CalculateUtils.getChartGroupList(positiveValue, negativeValue: negativeValue, segments: segments)
        //段数值列表
        
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - dateAreaHeight
        let gapHeight = chartHeight / CGFloat(segments)
        
        minChartY = 0
        maxChartY = chartHeight
        
        divideEqually = segmentArea.count - segments - 2 == 0 //分段结果 == 段数 + 2
        
        let zeroIndex = getSegmentIndex(0)
        if divideEqually == true {
            zeroChartY = CGFloat(zeroIndex - 1) * gapHeight + gapHeight * 0.5
        }else{
            zeroChartY = CGFloat(zeroIndex) * gapHeight
        }
        
    }
    
    private func getSegmentIndex(value:Int)->Int{
        for i in 0..<segmentArea.count{
            if segmentArea[i] == value{
                return i
            }
        }
        return -1
    }
    
    public override func drawRect(rect: CGRect) {
        if chartDataList == nil || chartDataList.count == 0 {
            return //没有一组数据
        }
        drawHorizontalLine()
        drawSourceLine()
        drawVerticalLine()
    }
    
    private func drawSourceLine(){
//        let viewWidth:CGFloat = self.frame.width
//        let dateGapWidth:CGFloat = viewWidth / CGFloat(dateList.count - 1)
        var linePath:UIBezierPath!
        for i in 0..<chartDataList.count{
            let value = chartDataList[i]
            let compareValue:CGFloat = getCompareValue(i)
            let lineX = getSourceLineX(i)
            let lineY = getSourceLineY(value,compareValue: compareValue)
            if chartType == .Column{
                linePath = UIBezierPath()
                linePath.lineWidth = getLineWidth()
                linePath.moveToPoint(CGPoint(x: lineX,y: zeroChartY))
                linePath.addLineToPoint(CGPoint(x: lineX, y: lineY))
                let rateValue = (value / compareValue - 1) * 100
                if rateValue > 0{
                    UICreaterUtils.colorRise.setStroke()
                }else{
                    UICreaterUtils.colorDrop.setStroke()
                }
                linePath.stroke()
            }else{
                if i == 0{
                    linePath = UIBezierPath()
                    linePath.lineWidth = getLineWidth()
                    linePath.lineJoinStyle = CGLineJoin.Round
                    linePath.lineCapStyle = CGLineCap.Round
                    linePath.moveToPoint(CGPoint(x: 0,y: lineY))
                }else{
                    linePath.addLineToPoint(CGPoint(x: lineX, y: lineY))
                }
            }
        }
        if chartType == .Line{
            lineColor.setStroke()
            linePath.stroke()
        }
        
    }
    
    private func drawVerticalLine(){
        let viewWidth:CGFloat = self.frame.width
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - dateAreaHeight
        let dataGapWidth:CGFloat = viewWidth / CGFloat(dateList.count - 1)
        var preDate = dateList[0]
        var lastDate = dateList[dateList.count - 1]
        
        let fmt = NSDateFormatter()
//        fmt.dateFormat = "MM-dd"
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let unitFlags:NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute]
        
        let label1 = UICreaterUtils.createLabel(10, UICreaterUtils.colorFlat, getDateLabel(fmt,unitFlags:unitFlags,calendar:calendar,nowDate:&preDate), true, chartLabelView)
        label1.frame.origin = CGPoint(x: 0, y: chartHeight + 2)
        
        let lastTime = lastDate.timeIntervalSince1970
        
        for i in 1..<dateList.count - 1{
            var nowDate = dateList[i]
            let nowTime:NSTimeInterval = nowDate.timeIntervalSince1970
            let preTime:NSTimeInterval = preDate.timeIntervalSince1970
            //            println("nowTime:\(nowTime)   preTime:\(preTime)")
            if lastTime - nowTime < timeGap{//最后的区域到不了
                break//直接跳出
            }
            if nowTime - preTime >= timeGap{//已经到目标区间了
                let lineX = dataGapWidth * CGFloat(i)
                //画线
                drawLine(CGPoint(x: lineX,y: 0),endPoint: CGPoint(x: lineX, y: chartHeight),isDash:true)
                
                let labelString = getDateLabel(fmt,unitFlags:unitFlags,calendar:calendar,nowDate:&nowDate)
                let label = UICreaterUtils.createLabel(10, UICreaterUtils.colorFlat, labelString, true, chartLabelView)
                label.frame.origin = CGPoint(x: lineX - label.frame.width / 2, y: chartHeight + 2)
//                if labelString == regularTimeString{
//                    preDate = dateList[i + 1] //非常特殊 直接找下一个
//                }else{
                    preDate = nowDate
//                }
            }
        }
        let label2 = UICreaterUtils.createLabel(10, UICreaterUtils.colorFlat, getDateLabel(fmt,unitFlags:unitFlags,calendar:calendar,nowDate:&lastDate,preDate:preDate), true, chartLabelView)
        label2.frame.origin = CGPoint(x: viewWidth - label2.frame.width, y: chartHeight + 2)
    }
    
    private var lineLabelColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    private func drawHorizontalLine(){
        let viewWidth:CGFloat = self.frame.width
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - dateAreaHeight
        let gapHeight = chartHeight / CGFloat(segments)
        
        drawLine(CGPoint(x: dashLineWidth,y: 0),endPoint: CGPoint(x: dashLineWidth, y: chartHeight),isDash:true)
        drawLine(CGPoint(x: viewWidth - dashLineWidth,y: 0),endPoint: CGPoint(x: viewWidth - dashLineWidth, y: chartHeight),isDash:true)
        
        for i in 0..<segmentArea.count{
            var lineY:CGFloat = 0
            if i == 0{
                lineY = dashLineWidth
            }else if i == segmentArea.count - 1{
                lineY = chartHeight - dashLineWidth
            }else if divideEqually == true {
                lineY = (CGFloat(i - 1) + 0.5) * gapHeight
            }else{
                lineY = CGFloat(i) * gapHeight
            }
            let startPoint:CGPoint = CGPoint(x: 0, y: lineY)
            let endPoint:CGPoint = CGPoint(x: viewWidth, y: lineY)
            if i == 0 || i == segmentArea.count - 1{//实线
                drawLine(startPoint,endPoint:endPoint)
            }else{//虚线
                drawLine(startPoint,endPoint:endPoint,isDash:true)
            }
            if (divideEqually == true && (i == 0 || i == segmentArea.count - 1)){
                continue
            }
            var textColor:UIColor
            if segmentArea[i] > 0{
                textColor = UICreaterUtils.colorRise
            }else if segmentArea[i] < 0{
                textColor = UICreaterUtils.colorDrop
            }else{
                textColor = UICreaterUtils.colorFlat
            }
            let label:UILabel = UICreaterUtils.createLabel(10,textColor,"\(segmentArea[i]).00%",true,chartLabelView)
            if i == 0{
                label.frame.origin = CGPoint(x: 4, y: lineY)
            }else{
                label.frame.origin = CGPoint(x: 4, y: lineY - label.frame.height)
            }
        }
    }
    private let dashLineWidth:CGFloat = 0.2
    private func drawLine(startPoint:CGPoint,endPoint:CGPoint,isDash:Bool = false){
        let context:CGContextRef = UIGraphicsGetCurrentContext()!;
        CGContextBeginPath(context)
        CGContextSetLineWidth(context, dashLineWidth);
        CGContextSetStrokeColorWithColor(context, lineLabelColor.CGColor);
        if isDash{
            CGContextSetLineDash(context, 0, [2,2], 2);
        }else{
            CGContextSetLineDash(context, 0, nil, 0);
        }
        CGContextMoveToPoint(context, startPoint.x, startPoint.y);
        CGContextAddLineToPoint(context, endPoint.x,endPoint.y);
        CGContextStrokePath(context);
        //        CGContextClosePath(context);
    }
    
    private func getGestureIndex(gestureX:CGFloat)->Int{
        var index:Int = Int(gestureX / getDateGapWidth())
        if index < 0{
            index = 0
        }else if index > dateList.count - 1{
            index = dateList.count - 1
        }
        return index
    }
    
    private func getSourceLineX(index:Int)->CGFloat{
        let dateGapWidth = getDateGapWidth()
        switch (chartType) {
        case .Column:
            return dateGapWidth * CGFloat(index) + dateGapWidth / 2
        case .Line:
            return dateGapWidth * CGFloat(index)
        }
    }
    
    private func getSourceLineY(value:CGFloat,compareValue:CGFloat)->CGFloat{
        let maxValue = abs(segmentArea[0])
        let minValue = abs(segmentArea[segmentArea.count - 1])
        let rateValue = (value / compareValue - 1) * 100
        var lineY:CGFloat
        if rateValue > 0{
            lineY = zeroChartY - rateValue / CGFloat(maxValue) * (zeroChartY - minChartY)
        }else if rateValue < 0{
            lineY = zeroChartY + rateValue / CGFloat(minValue) * (zeroChartY - maxChartY)
        }else{
            lineY = zeroChartY
        }
        return lineY
    }
    
    private func getLineWidth()->CGFloat{
        switch(chartType){
        case .Column:
            let dateGapWidth = getDateGapWidth()
            return dateGapWidth * 2 / 3
        case .Line:
            return lineWidth
        }
    }
    
    public func getCompareValue(index:Int)->CGFloat{
        var value:CGFloat!
        switch (compareType) {
        case .Previous:
            if index - 1 < 0{//第一个数值是自定义的
                value = compareRegularValue
            }else{
                value = chartDataList[index - 1]
            }
        case .First:
            value = chartDataList[0]
        case .Regular:
            value = compareRegularValue
        }
        if value == 0{
            value = zeroValueTag
            print("数据中被比较的数为0!!!")
        }
        return value
    }
    
    private func getDateGapWidth()->CGFloat{
        let viewWidth:CGFloat = self.frame.width
        switch(chartType){
        case .Column:
            return viewWidth / CGFloat(dateList.count)
        case .Line:
            return viewWidth / CGFloat(dateList.count - 1)
        }
    }
    let regularTimeString = "11:30/13:00"
    private func getDateLabel(fmt:NSDateFormatter,unitFlags:NSCalendarUnit,calendar:NSCalendar?,inout nowDate:NSDate,preDate:NSDate? = nil)->String{
        let nowComps = calendar?.components(unitFlags, fromDate: nowDate)
        switch(dateType){
            case .Normal:
                fmt.dateFormat = "MM-dd"
                if preDate != nil{
                    let preComps = calendar?.components(unitFlags, fromDate: preDate!)
                    if preComps?.year != nowComps?.year{
                        fmt.dateFormat = "yyyy-MM-dd"
                    }
                }
            case .Hour:
                fmt.dateFormat = "HH:mm"
                //                println("hour:\(nowComps!.hour)  minute:\(nowComps!.minute)")
                if nowComps?.hour == 11 && nowComps?.minute == 30{ //11:30
                    nowDate = NSDate(timeInterval: 90 * 60, sinceDate: nowDate) //偏移1个半小时
                    return regularTimeString //固定时间
                }
        }
//        if preDate == nil{
//            switch(dateType){
//            case .Normal:
//                fmt.dateFormat = "MM-dd"
//            case .Hour:
//                let nowComps = calendar?.components(unitFlags, fromDate: nowDate)
//                fmt.dateFormat = "HH:mm"
////                println("hour:\(nowComps!.hour)  minute:\(nowComps!.minute)")
//                if nowComps?.hour == 11 && nowComps?.minute == 30{ //11:30
//                    return "11:30/13:00" //固定时间
//                }
//            }
//        }else{
//            let preComps = calendar?.components(unitFlags, fromDate: preDate!)
//            let nowComps = calendar?.components(unitFlags, fromDate: nowDate)
//            switch(dateType){
//            case .Normal:
//                if preComps?.year != nowComps?.year{
//                    fmt.dateFormat = "yyyy-MM-dd"
//                }else{
//                    fmt.dateFormat = "MM-dd"
//                }
//            case .Hour:
//                fmt.dateFormat = "HH:mm"
//            }
//        }
        return fmt.stringFromDate(nowDate)
    }
    
}
