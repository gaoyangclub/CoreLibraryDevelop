//
//  UITrendChart.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/11/28.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit
@objc public protocol TrendChartDelegate {
    // MARK: - Delegate functions
    optional func touchChartLineBegin(index: Int)
    optional func touchChartLineEnd()
}
public class UIGroupLineChart: UIView,UIGestureRecognizerDelegate {
    
    public weak var delegate:TrendChartDelegate?
    
    /** 横向日期数组 */
    public var dateList:[NSDate]!{
        didSet{
            setNeedsLayout()
        }
    }
    /** 纵向数据二维数组 */
    public var chartDataSource:Array<Array<CGFloat>>!{
        didSet{
            setNeedsLayout()
        }
    }
    /** 数据集对应颜色 */
    public var lineColorList:[UIColor]!{
        didSet{
            setNeedsLayout()
        }
    }
    /** 数据集对应线条宽度 */
    public var lineWidthList:[CGFloat]!{
        didSet{
            setNeedsLayout()
        }
    }
    /** 数据名称数组 */
    public var titleList:[String]!{
        didSet{
            setNeedsLayout()
        }
    }
    public var segments:Int = 5{
        didSet{
            setNeedsLayout()
        }
    }//横向分段数
    public var bottomHeight:CGFloat = 38{
        didSet{
            setNeedsLayout()
        }
    }//
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
    
    public override func layoutSubviews() {
        backgroundColor = UIColor.clearColor()
        
        if chartDataSource == nil || chartDataSource.count == 0 || chartDataSource[0].count == 0{
            return //没有一组数据
        }
        measure()
        initBottomView()
        initChartLabel()
        initGestureRecognizer()
        setNeedsDisplay()
    }
    
    private var gestrueArea:UIView!
    var panGestrue:UIPanGestureRecognizer!
    var tapGestrue:UITapGestureRecognizer!
    /** 添加按下松开和拖动手势 */
    private func initGestureRecognizer(){
        if panGestrue == nil{
            panGestrue = UIPanGestureRecognizer(target: self, action: "panHandler:")
            chartLabelView.addGestureRecognizer(panGestrue)
//            panGestrue.enabled = false
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
//    private var hasPan:Bool = false
//    private var touches:Set<NSObject>!
//    private var event:UIEvent!
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //            super.touchesMoved(Set<NSObject>(), withEvent: event)
//        self.touches = touches
//        self.event = event
        if touches.count > 0{
            let nowTouch = touches[touches.startIndex] as UITouch
            let nowPoint = nowTouch.locationInView(self)
            
            let dirtX = abs(nowPoint.x - prevTouchPoint.x)
            let dirtY = abs(nowPoint.y - prevTouchPoint.y)
//            println("dirtX:\(dirtX)  dirtY:\(dirtY)")
            if  dirtX > dirtY {//横向移动
//                if !hasPan{
//                    hasPan = true
////                    chartLabelView.addGestureRecognizer(panGestrue)
//                }
                panGestrue.enabled = true
//                println("横向注册手势")
            }else{
                panGestrue.enabled = false
//                println("纵向移动")
            }
        }
//        println("滑动中")
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.touches = touches
//        self.event = event
        if touches.count > 0{
            let prevTouch = touches[touches.startIndex] as UITouch
            prevTouchPoint = prevTouch.locationInView(self)
        }
//        println("开始移动")
    }
////
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        super.touchesCancelled(Set<NSObject>(), withEvent: event)
        resumePan()
    }
//
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesEnded(Set<NSObject>(), withEvent: event)
        resumePan()
    }
    
//    func tapHandler(sender:UITapGestureRecognizer){
//        println(sender)
//    }
    
    //横向滑动可以 纵向向外冒泡
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool{
//        var translation:CGPoint = panGestrue.velocityInView(chartLabelView)
//        println(translation)
        
        let nowPoint:CGPoint = touch.locationInView(self)
        let prevPoint:CGPoint = touch.previousLocationInView(self)
        print("nowPoint:\(nowPoint)  prevPoint:\(prevPoint)")
        return false//CGPointEqualToPoint(nowPoint,prevPoint) || abs(nowPoint.x - prevPoint.x) > abs(nowPoint.y - prevPoint.y)
    }
    
    func tapHandler(sender:UIGestureRecognizer){
        if sender.numberOfTouches() > 0{
            measureGestruePoint(sender)
        }
    }
    
    private func measureGestruePoint(sender:UIGestureRecognizer){
        let viewWidth:CGFloat = self.frame.width
        let nowPoint:CGPoint = sender.locationOfTouch(0, inView: self)
//        if nowPoint.x < 0 || nowPoint.x > viewWidth{ //超边界
//            return
//        }
        let dataGapWidth:CGFloat = viewWidth / CGFloat(dateList.count - 1)
        var index:Int = Int(nowPoint.x / dataGapWidth)
        if index < 0{
            index = 0
        }else if index > dateList.count - 1{
            index = dateList.count - 1
        }
        showGestrueLine(index)
    }
    
    func panHandler(sender:UIGestureRecognizer){
        
        if sender.state == .Ended{
//            println("拖动结束")
            hideGestrueLine()
        }else if sender.numberOfTouches() > 0{
//            var nowPoint:CGPoint = sender.locationOfTouch(0, inView: self)
//            if prevTouchPoint == nil{
//                prevTouchPoint = nowPoint
//            }else{
//                if abs(nowPoint.x - prevTouchPoint!.x) < abs(nowPoint.y - prevTouchPoint!.y){//纵向移动
//                    panGestrue.enabled = false
//                    chartLabelView.resignFirstResponder() //去除第一响应
//                }else{
                    measureGestruePoint(sender)
//                }
//            }
        }
//        if sender.numberOfTouches() > 0{
//            var nowPoint:CGPoint = sender.locationOfTouch(0, inView: self)
//            if prevTouchPoint == nil{
//                prevTouchPoint = nowPoint
//            }else{
//                if abs(nowPoint.x - prevTouchPoint!.x) < abs(nowPoint.y - prevTouchPoint!.y){//纵向移动
////                    println("纵向交互")
//                    panGestrue.enabled = false
//                    panGestrue.cancelsTouchesInView = false
//                    chartLabelView.removeGestureRecognizer(panGestrue)
//                }
//            }
//        }
//        println("移动中")
    }
    var themeIndex:Int = 0 //
    private func showGestrueLine(index:Int){
        let viewWidth:CGFloat = self.frame.width
        let dataGapWidth:CGFloat = viewWidth / CGFloat(dateList.count - 1)
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - bottomHeight - dateAreaHeight
        
        gestrueArea.removeAllSubViews()
        
        let lineV:UIView = UIView(frame: CGRectMake(CGFloat(index) * dataGapWidth, 0, 1, chartHeight))
        lineV.backgroundColor = UICreaterUtils.colorFlat
        gestrueArea.addSubview(lineV)
        
        let firstValue = chartDataSource[themeIndex][0]
        let value = chartDataSource[themeIndex][index]
        let lineH:UIView = UIView(frame: CGRectMake(0,getSourceLineY(value,firstValue: firstValue),viewWidth, 1))
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
//        hasPan = false
        if (panGestrue != nil){
            panGestrue.enabled = true
//            println("恢复横向手势")
            //            chartLabelView.removeGestureRecognizer(panGestrue)
        }
        prevTouchPoint = nil
    }
    
    private func initChartLabel(){
        if chartLabelView == nil{
            chartLabelView = UIView()
            self.addSubview(chartLabelView)
            chartLabelView.snp_makeConstraints(closure: { [weak self](make) -> Void in
                make.left.right.top.equalTo(self!)
                make.bottom.equalTo(self!.bottomView.snp_top)
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
    
    private func initBottomView(){
        if bottomView == nil{
            bottomView = UIView()
            self.addSubview(bottomView)
        }
        bottomView.snp_makeConstraints(closure: { [weak self](make) -> Void in
            make.left.right.bottom.equalTo(self!)
            make.height.equalTo(self!.bottomHeight)
        })
        bottomView.removeAllSubViews()
        if titleList == nil || titleList.count == 0{
            return//没有底部标题栏
        }
        let viewWidth:CGFloat = self.frame.width
        var firstRect:UIView!
        var preLabel:UIView!
        let rectWidth:CGFloat = 12
        let rectHeight:CGFloat = 11
        var containWidth:CGFloat = 0
        let textGap:CGFloat = 6
        let rectGap:CGFloat = 10
        for i in 0..<titleList.count{
            let title = titleList[i]
            let rect:UIView = UIView()
            rect.backgroundColor = lineColorList[i]
            bottomView.addSubview(rect)
            if firstRect == nil{
                firstRect = rect
                containWidth += rectWidth
            }else{
                rect.snp_makeConstraints(closure: { [weak self](make) -> Void in
                    make.left.equalTo(preLabel.snp_right).offset(rectGap)
                    make.width.equalTo(rectWidth)
                    make.height.equalTo(rectHeight)
                    make.centerY.equalTo(self!.bottomView)
                })
                containWidth += rectGap + rectWidth
            }
            let label:UILabel = UICreaterUtils.createLabel(12,UICreaterUtils.colorFlat,title,true,bottomView)
            label.snp_makeConstraints(closure: { [weak self](make) -> Void in
                make.left.equalTo(rect.snp_right).offset(textGap)
                make.centerY.equalTo(self!.bottomView)
            })
            containWidth += label.frame.width + textGap
            preLabel = label
        }
        let firstLeft:CGFloat = (viewWidth - containWidth) / 2
        firstRect.snp_makeConstraints { [weak self](make) -> Void in
            make.left.equalTo(self!.bottomView).offset(firstLeft)
            make.width.equalTo(rectWidth)
            make.height.equalTo(rectHeight)
            make.centerY.equalTo(self!.bottomView)
        }
    }
    
    private let dateAreaHeight:CGFloat = 12
    
    private var minChartY:CGFloat!
    private var maxChartY:CGFloat!
    private var zeroChartY:CGFloat!
    
    private var divideEqually:Bool!
    private var segmentArea:[Int]!
    
    private var bottomView:UIView!
    private var chartLabelView:UIView!
    
//    private var positiveValue:Int!
//    private var negativeValue:Int!
    
    //测量坐标系 获取0点位置坐标 获取横向间距
    private func measure(){
        var minValue:CGFloat = 0
        var maxValue:CGFloat = 0
        for i in 0..<chartDataSource.count{
            let chartSource = chartDataSource[i]
            let firstValue:CGFloat = chartDataSource[i][0]
            for value in chartSource{
                let rateValue = (value / firstValue - 1) * 100
                if rateValue < minValue{
                    minValue = rateValue
                }else if rateValue > maxValue{
                    maxValue = rateValue
                }
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
        let chartHeight:CGFloat = viewHeight - bottomHeight - dateAreaHeight
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
        if chartDataSource == nil || chartDataSource.count == 0 || chartDataSource[0].count == 0{
            return //没有一组数据
        }
        drawHorizontalLine()
        drawSourceLine()
        drawVerticalLine()
    }
    
    private func drawSourceLine(){
        let viewWidth:CGFloat = self.frame.width
        let dataGapWidth:CGFloat = viewWidth / CGFloat(dateList.count - 1)
        for i in 0..<chartDataSource.count{
            let firstValue:CGFloat = chartDataSource[i][0]
            let chartSource = chartDataSource[i]
            let linePath = UIBezierPath()
            linePath.moveToPoint(CGPoint(x: 0,y: zeroChartY))
            for j in 1..<chartSource.count{
                let value = chartSource[j]
                linePath.addLineToPoint(CGPoint(x: CGFloat(j) * dataGapWidth, y: getSourceLineY(value,firstValue: firstValue)))
            }
            linePath.lineJoinStyle = CGLineJoin.Round
            linePath.lineCapStyle = CGLineCap.Round
            linePath.lineWidth = lineWidthList[i]
            lineColorList[i].setStroke()
            linePath.stroke()
        }
    }
    
    
    private func getSourceLineY(value:CGFloat,firstValue:CGFloat)->CGFloat{
        let maxValue = abs(segmentArea[0])
        let minValue = abs(segmentArea[segmentArea.count - 1])
        let rateValue = (value / firstValue - 1) * 100
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
    
    private func drawVerticalLine(){
        let viewWidth:CGFloat = self.frame.width
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - bottomHeight - dateAreaHeight
        let dataGapWidth:CGFloat = viewWidth / CGFloat(dateList.count - 1)
        var preDate = dateList[0]
        let lastDate = dateList[dateList.count - 1]
        
        let fmt = NSDateFormatter()
        fmt.dateFormat = "MM-dd"
        
        let label1 = UICreaterUtils.createLabel(10, UICreaterUtils.colorFlat, fmt.stringFromDate(preDate), true, chartLabelView)
        label1.frame.origin = CGPoint(x: 0, y: chartHeight + 2)
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let unitFlags:NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month]
        
        let lastTime = lastDate.timeIntervalSince1970
        
        for i in 1..<dateList.count - 1{
            let nowDate = dateList[i]
            let nowTime:NSTimeInterval = nowDate.timeIntervalSince1970
            let preTime:NSTimeInterval = preDate.timeIntervalSince1970
//            println("nowTime:\(nowTime)   preTime:\(preTime)")
            if lastTime - nowTime < timeGap{//最后的区域到不了
                break//直接跳出
            }
            if nowTime - preTime > timeGap{//已经到目标区间了
                let lineX = dataGapWidth * CGFloat(i)
                //画线
                drawLine(CGPoint(x: lineX,y: 0),endPoint: CGPoint(x: lineX, y: chartHeight),isDash:true)
                let preComps = calendar?.components(unitFlags, fromDate: preDate)
                let nowComps = calendar?.components(unitFlags, fromDate: nowDate)
                if preComps?.year != nowComps?.year{
                    fmt.dateFormat = "yyyy-MM-dd"
                }else{
                    fmt.dateFormat = "MM-dd"
                }
                let label = UICreaterUtils.createLabel(10, UICreaterUtils.colorFlat, fmt.stringFromDate(nowDate), true, chartLabelView)
                label.frame.origin = CGPoint(x: lineX - label.frame.width / 2, y: chartHeight + 2)
                preDate = nowDate
            }
        }
        let preComps = calendar?.components(unitFlags, fromDate: preDate)
        let lastComps = calendar?.components(unitFlags, fromDate: lastDate)
        if preComps?.year != lastComps?.year{
            fmt.dateFormat = "yyyy-MM-dd"
        }else{
            fmt.dateFormat = "MM-dd"
        }
        let label2 = UICreaterUtils.createLabel(10, UICreaterUtils.colorFlat, fmt.stringFromDate(lastDate), true, chartLabelView)
        label2.frame.origin = CGPoint(x: viewWidth - label2.frame.width, y: chartHeight + 2)
        
    }
    
    private var lineLabelColor = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    private func drawHorizontalLine(){
        let viewWidth:CGFloat = self.frame.width
        let viewHeight:CGFloat = self.frame.height
        let chartHeight:CGFloat = viewHeight - bottomHeight - dateAreaHeight
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
        let context:CGContextRef = UIGraphicsGetCurrentContext()!
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
    
    
    

}
