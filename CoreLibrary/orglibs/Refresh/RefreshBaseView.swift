//
//  RefreshBaseView.swift
//  PullRefreshScrollerTest
//
//  Created by 高扬 on 15/9/4.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

let RefreshLabelTextColor:UIColor = UIColor(red: 150.0/255, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1)

public class RefreshBaseView: UIView {
    
    //控件的刷新状态
    enum RefreshState {
        case  Pulling               // 松开就可以进行刷新的状态
        case  Normal                // 普通状态
        case  Refreshing            // 正在刷新中的状态
        case  Nodata                //暂无更多
    }
    
    private var _scrollView:UIScrollView?
    //  父控件
    public var scrollView:UIScrollView!{
        set(newValue){
            changeScrollview(newValue)
            _scrollView = newValue
        }get{
            return _scrollView
        }
    }
    
    private var hasObserver:Bool = false
    public func changeScrollview(newSuperview: UIScrollView!) {
        // 旧的父控件移除侦听
        removeSuperViewObservers()
        // 新的父控件
        if (newSuperview != nil) {
            newSuperview.addObserver(self, forKeyPath: RefreshContentSize as String, options: NSKeyValueObservingOptions.New, context: nil)
            newSuperview.addObserver(self, forKeyPath: RefreshContentOffset as String, options: NSKeyValueObservingOptions.New, context: nil)
            newSuperview.addObserver(self, forKeyPath: RefreshContentInset as String, options: NSKeyValueObservingOptions.New, context: nil)
            
            hasObserver = true
            
            var rect:CGRect = self.frame
            // 设置宽度   位置
            rect.size.width = newSuperview.frame.size.width
            rect.origin.x = 0
            self.frame = rect;
            //UIScrollView
        }
    }
    
    private func removeSuperViewObservers(){
        if (_scrollView != nil && hasObserver) {
            _scrollView!.removeObserver(self, forKeyPath: RefreshContentSize as String, context: nil)
            _scrollView!.removeObserver(self, forKeyPath: RefreshContentOffset as String, context: nil)
            _scrollView!.removeObserver(self, forKeyPath: RefreshContentInset as String, context: nil)
        }
    }
    
    deinit{
        removeSuperViewObservers()
//        print("RefreshBaseView销毁并移除侦听")
    }
    
    // 内部的控件
    var statusLabel:UILabel!
    var arrowImage:UIArrowView?//UIImageView?
    var activityView:UIActivityIndicatorView!
    
    //回调
    var beginRefreshingCallback:(()->Void)?
    
    // 交给子类去实现 和 调用
    var oldState:RefreshState?
    
//    var _state:RefreshState = RefreshState.Normal;
    var State:RefreshState = RefreshState.Normal{
            willSet{
            }
            didSet{
                
            }
    }
    
    func showArrowState(newValue:RefreshState){

        if self.State == newValue {
            return
        }
        switch newValue {
        case RefreshState.Normal,RefreshState.Pulling:
            if arrowImage != nil{
                self.arrowImage!.hidden = false
            }
            self.activityView.stopAnimating()
            break
        case RefreshState.Refreshing:
            if arrowImage != nil{
                self.arrowImage!.hidden = true
            }
            activityView.startAnimating()
            beginRefreshingCallback!()
            break
        case RefreshState.Nodata:
            if arrowImage != nil{
                self.arrowImage!.hidden = true
            }
            activityView.stopAnimating()
            break
//        default:
//            break
        }
    }
    
    //控件初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        //状态标签
//        statusLabel = UILabel()
//        statusLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
//        statusLabel.font = UIFont.boldSystemFontOfSize(13)
//        statusLabel.textColor = RefreshLabelTextColor
//        statusLabel.backgroundColor =  UIColor.clearColor()
//        statusLabel.textAlignment = NSTextAlignment.Center
//        self.addSubview(statusLabel)
//        //箭头图片
//        arrowImage = UIImageView(image: UIImage(named: "arrow.png"))
//        arrowImage.autoresizingMask = UIViewAutoresizing.FlexibleWidth
//        //UIViewAutoresizing.FlexibleLeftMargin |  UIViewAutoresizing.FlexibleRightMargin
//        self.addSubview(arrowImage)
//        //状态标签
//        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
//        activityView.bounds = self.arrowImage.bounds
//        activityView.autoresizingMask = self.arrowImage.autoresizingMask
//        self.addSubview(activityView)
//        //自己的属性
//        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
//        self.backgroundColor = UIColor.clearColor()
//        //设置默认状态
//        //        self.State = RefreshState.Normal;
        
        showSubView();
    }
    
    func showSubView(){
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //监听UIScrollView的属性
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if (!self.userInteractionEnabled || self.hidden){
//            return
//        }
        if RefreshContentSize.isEqualToString(keyPath!){
            adjustFrameWithContentSize()
        }else if RefreshContentOffset.isEqualToString(keyPath!) {
            if self.State == RefreshState.Refreshing{
                return
            }
            adjustStateWithContentOffset()
        }else if "contentInset".isEqualToString(keyPath!){
//            println("scrollViewInset.top:\(scrollView.contentInset.top)")
        }
    }
    
    //当scroller内容高度改变时触发
    func adjustFrameWithContentSize(){
        
    }
    //当滚动位置发生改变时触发
    func adjustStateWithContentOffset(straight:Bool = false){
        
    }
    // 刷新相关
    // 是否正在刷新
    func isRefreshing()->Bool{
        return RefreshState.Refreshing == self.State;
    }
    
    // 开始刷新
    func beginRefreshing(){
        // self.State = RefreshState.Refreshing;
//        if (self.window != nil) {
            self.State = RefreshState.Refreshing;
//        }
    }
    
//    //结束刷新
//    func endRefreshing(){
////        let delayInSeconds:Double = 0.3
////        var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds));
//        
////        dispatch_after(popTime, dispatch_get_main_queue(), {
//            self.State = RefreshState.Normal;
////        })
//    }
    
    func noDataRefreshing(){
        self.State = RefreshState.Nodata
    }
    
    //重置回初始化状态
    func reset(){
//        scrollView.contentInset.bottom = 0;
        self.oldState = RefreshState.Normal
        self.State = RefreshState.Normal //状态恢复到默认
    }
    
    
    
    


}
