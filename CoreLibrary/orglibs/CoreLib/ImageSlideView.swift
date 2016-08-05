//
//  ImageSlideView.swift
//  ImageSlideViewTest
//
//  Created by 高扬 on 15/8/16.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class ImageSlideView: UIControl {
    
    
    //     Only override drawRect: if you perform custom drawing.
    //     An empty implementation adversely affects performance during animation.
    public override func drawRect(rect: CGRect) {
        reloadData()
        print("开始渲染视图")
    }
    
    
    enum ImageTweenStyle:Int{
        case Fade
        case Flip
    }
    
    var tweenStyle:ImageTweenStyle = .Fade
    private var timer: NSTimer?
    
    private var imageViewPrev:UIImageView?
    private var imageViewNext:UIImageView?
    
    var autoRound:Bool = true //自动轮播
    
    public override func layoutSubviews(){
        //        super.layoutSubviews()
        print("重新布局UI")
        reloadData()
        //        setNeedsDisplay()
    }
    
    //前后两张图片
    private var _currentPage:Int = 0 //当前页
    
    var selectedIndex:Int{
        get{
            return self._currentPage
        }
        set(value){
            if _currentPage != value{
                _currentPage = value
                setNeedsDisplay()
            }
        }
    }
    
    private var _pageControlBottom:CGFloat = 0
    var pageControlBottom:CGFloat{
        get {
            return self._pageControlBottom
        }
        set(value){
            if _pageControlBottom != value{
                _pageControlBottom = value
                setNeedsDisplay()
            }
        }
    }
    
    private var pageControl:UIPageControl?
    
    private var _dataSource:[String]? //图片url数据
    var dataSource: [String]? {
        get {
            return self._dataSource
        }
        set(newValue){
            _dataSource = newValue
            if _dataSource != nil{ //有数据
                //                reset = true //全部重置
                _currentPage = 0
                setNeedsDisplay()
            }
        }
    }
    
    private var activeTurnList:[(Bool,Int)] = []//连续切换方向列表
    
    private var isTween:Bool = false //是否正在缓动
    
    var timeDelay:Int = 5 //5秒后切换页面
    
    //    private var reset:Bool = true
    
    //重新加载数据生成视图
    func reloadData(){
        clipsToBounds = true
        
        if _dataSource == nil{
            return //数据不存在
        }
        
        if imageViewNext == nil { //不存在
            imageViewNext = UIImageView()
            self.addSubview(imageViewNext!)
        }
        
        if imageViewPrev == nil { //不存在
            imageViewPrev = UIImageView()
            self.addSubview(imageViewPrev!)
        }
        
        imageViewNext?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        imageViewPrev?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        
        if pageControl == nil{
            pageControl = UIPageControl()
            //            pageControl?.frame.size = sg
            self.addSubview(pageControl!)
            
            pageControl?.addTarget(self, action: "pageControlChange", forControlEvents: UIControlEvents.ValueChanged)
            pageControl!.translatesAutoresizingMaskIntoConstraints = false
            
            let constraint = NSLayoutConstraint(item: pageControl!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
            
            self.addConstraint(constraint)
            //            var color:UIColor = UIColor.blackColor()
            //            color.colorWithAlphaComponent(0.5)
            //            pageControl?.pageIndicatorTintColor = color
        }
        
        showPageControlBottm()
        
        //        if(reset){ //数据重置
        pageControl?.numberOfPages = self._dataSource!.count
        //        }
        
        if _currentPage > self._dataSource!.count{
            _currentPage = 0 //出界只能清零
        }
        
        pageControl?.currentPage = _currentPage
        
        BatchLoaderForSwift.loadFile(_dataSource![_currentPage], callBack: imageLoadedThenPage)
        //        showCurrentPage()
        
        //        println("reload complete")
        
        //        reset = false
    }
    
    func timeHandler(){
        gotoNextPage() //找下一个
    }
    
    func addAllEvent(){
        let leftSwip:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "gotoPrevPage")
        leftSwip.direction = UISwipeGestureRecognizerDirection.Left
        addGestureRecognizer(leftSwip)
        
        let rightSwip:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "gotoNextPage")
        rightSwip.direction = UISwipeGestureRecognizerDirection.Right
        addGestureRecognizer(rightSwip)
    }
    
    func gotoPrevPage(){
        if autoRound || _currentPage - 1 >= 0{
            _currentPage = getPrevPage()
            turnPage(true,nowPage:_currentPage)
        }
    }
    
    func gotoNextPage(){
        if autoRound || _currentPage + 1 <= _dataSource!.count - 1 {
            _currentPage = getNextPage()
            turnPage(false,nowPage:_currentPage)
        }
    }
    
    func pageControlChange(){
        if pageControl?.currentPage != _currentPage{
            //变化图片
            let isLeft:Bool = pageControl!.currentPage < _currentPage
            _currentPage = pageControl!.currentPage
            //            showCurrentPage()
            turnPage(isLeft,nowPage:_currentPage)
        }
    }
    
    //    private var animation:CABasicAnimation?
    private func turnPage(isLeft:Bool,nowPage:Int){
        
        if _dataSource == nil{
            return //数据不存在
        }
        
        if(isTween){
            let active = (isLeft,nowPage)
            activeTurnList.append(active)
            return
        }
        
        pageControl?.currentPage = nowPage//同步切换位置
        
        BatchLoaderForSwift.loadFile(_dataSource![nowPage]){ image in
            self.imageViewNext?.image = image
        }//, callBack: imageLoaded, imageViewNext!)
        
        //        imageViewNext?.image = _dataSource![nowPage] as? UIImage
        
        if(tweenStyle == ImageTweenStyle.Fade){
            //        if animation != nil{
            //            animation?.delegate = nil //清理
            //        }
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = imageViewPrev?.alpha
            animation.toValue = 0
            animation.duration = 0.5
            animation.delegate = self
            
            
            //            imageViewPrev?.layer.removeAllAnimations() //先清除之前的缓动
            imageViewPrev?.layer.addAnimation(animation, forKey: "Image-opacity")
        }else{
            if(isLeft){
                imageViewNext?.layer.position = CGPoint(x: frame.width * 3 / 2, y: frame.height / 2)
                
                let animationPrev = CABasicAnimation(keyPath: "position")
                animationPrev.toValue = NSValue(CGPoint:CGPoint(x:-frame.width / 2, y:frame.height / 2))
                animationPrev.duration = 0.5
                animationPrev.delegate = self
                
                //        imageViewPrev?.layer.removeAllAnimations()
                imageViewPrev?.layer.addAnimation(animationPrev, forKey: "Image-move-prev")
                
                let animationNext = CABasicAnimation(keyPath: "position")
                animationNext.toValue = NSValue(CGPoint:CGPoint(x:frame.width / 2, y:frame.height / 2))
                animationNext.duration = 0.5
                //        imageViewNext?.layer.removeAllAnimations()
                imageViewNext?.layer.addAnimation(animationNext, forKey: "Image-move-next")
            }else{
                imageViewNext?.layer.position = CGPoint(x: -frame.width / 2, y: frame.height / 2)
                
                let animationPrev = CABasicAnimation(keyPath: "position")
                animationPrev.toValue = NSValue(CGPoint:CGPoint(x:frame.width * 3 / 2, y:frame.height / 2))
                animationPrev.duration = 0.5
                animationPrev.delegate = self
                
                imageViewPrev?.layer.addAnimation(animationPrev, forKey: "Image-move-prev")
                
                let animationNext = CABasicAnimation(keyPath: "position")
                animationNext.toValue = NSValue(CGPoint:CGPoint(x:frame.width / 2, y:frame.height / 2))
                animationNext.duration = 0.5
                
                imageViewNext?.layer.addAnimation(animationNext, forKey: "Image-move-next")
            }
            
        }
        
        timer?.invalidate() //交互动作让时间失效
        timer = nil
        isTween = true
        
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        isTween = false
        imageViewPrev?.alpha = 1//恢复
        imageViewPrev?.layer.position = CGPoint(x:frame.width / 2, y:frame.height / 2) //恢复
        
        showCurrentPage(imageViewNext!.image!)
        if(activeTurnList.count > 0){//说明还有后续动作
            let active = activeTurnList.removeAtIndex(0) //头部取出
            turnPage(active.0,nowPage:active.1) //继续下一个动作
        }
    }
    
    //    func imageLoaded(data:UIImage?,params:[AnyObject]){
    //        let imageView = params[0] as! UIImageView//原视图
    //        //        var url = params[1] //原图片地址
    //        imageView.image = data! //显示
    //    }
    
    private var pageConstraint:NSLayoutConstraint?
    private func showPageControlBottm(){
        if pageControl != nil{
            if pageConstraint != nil{
                self.removeConstraint(pageConstraint!)
            }
            pageConstraint = NSLayoutConstraint(item: pageControl!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -_pageControlBottom)
            //创建一个居中父容器x的约束
            self.addConstraint(pageConstraint!)
        }
    }
    
    private func showCurrentPage(image:UIImage){
        //        BatchLoaderUtil.loadFile(url, callBack: imageLoaded,imageViewPrev!)
        imageViewPrev?.image = image//_dataSource![_currentPage]
        imageViewNext?.image = nil //清空
        if autoRound{
            if timer != nil{
                timer?.invalidate()
                timer = nil //原先的清除
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(Double(timeDelay) as NSTimeInterval, target: self, selector: "timeHandler", userInfo: nil, repeats: false) //重新开始计时
        }
    }
    
    func imageLoadedThenPage(data:UIImage?){//,params:[AnyObject]
        //        var nextCall:(image:UIImage)->Void = params[0] as! (image:UIImage)->Void
        //        nextCall(image: data!)
        self.showCurrentPage(data!)
    }
    
    private func getPrevPage()->Int{
        if _currentPage - 1 < 0{
            return _dataSource!.count - 1
        }
        return _currentPage - 1
    }
    
    private func getNextPage()->Int{
        if _currentPage + 1 > _dataSource!.count - 1{
            return 0
        }
        return _currentPage + 1
        
    }
    
    init() {
        super.init(frame:CGRectZero)
    }
    
    init(frame: CGRect,dataSource:[String]? = nil) {
        super.init(frame: frame)
        self.dataSource = dataSource //添加数据并显示
        addAllEvent()
    }
    
    public required init?(coder aDecoder: NSCoder) { //屏蔽该初始化方法
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}
