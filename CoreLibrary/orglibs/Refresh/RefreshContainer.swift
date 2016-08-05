
//
//  RefreshContainer.swift
//  PullRefreshScrollerTest
//
//  Created by 高扬 on 15/10/24.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class RefreshContainer: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    public func addHeaderWithCallback( view:RefreshHeaderView, callback:(() -> Void)!){
        removeHeader()
//        view.scrollView = self
        headerView = view
        view.beginRefreshingCallback = callback
        view.State = .Normal
    }
    
    public func addFooterWithCallback( view:RefreshFooterView, callback:(() -> Void)!){
        removeFooter()
//        view.scrollView = self
//        self.addSubview(view)
        footerView = view
        view.beginRefreshingCallback = callback
        view.State = .Normal
    }
    
    public var headerView:RefreshHeaderView?{
        didSet{
            self.setNeedsLayout()
        }
    }
    public var footerView:RefreshFooterView?{
        didSet{
            self.setNeedsLayout()
        }
    }
    public var scrollerView:UIScrollView!{
        didSet{
            self.setNeedsLayout()
        }
    }
    
    public override func layoutSubviews(){
        super.layoutSubviews();
        //        println("viewDidLayoutSubviews")
        customScrollerView();
    }
    
    private func customScrollerView(){
//        removeHeader();
//        removeFooter();
        
        if headerView != nil{
            headerView?.scrollView = scrollerView
            self.addSubview(headerView!)
        }
//        scrollerView.snp_makeConstraints { (make) -> Void in
//            make.left.right.top.bottom.equalTo(self)
//        }
//        scrollerView.frame = self.frame
//        scrollerView.setTranslatesAutoresizingMaskIntoConstraints(true)
        self.addSubview(scrollerView)
//        scrollerView.autoresizingMask = UIViewAutoresizing.FlexibleWidth //根据父容器宽度自动变化
        scrollerView.snp_makeConstraints { (make) -> Void in
            make.left.right.top.bottom.equalTo(self)
        }
        
        if(footerView != nil){
            footerView!.scrollView = scrollerView
            scrollerView.addSubview(footerView!)
        }
        
        if headerBeginRefresh{
            headerBeginRefresh = false
            headerView?.beginRefreshing()
        }
        
//        if footerBeginRest {
//            footerBeginRest = false
//            footerView?.reset()
//        }
        
        if headerBeginRest{ //再刷一次
            headerBeginRest = false
            headerView?.reset()
        }
        
    }
    
    private func removeHeader()
    {
        for view : AnyObject in self.subviews{
            if view is RefreshHeaderView{
                view.removeFromSuperview()
            }
        }
    }
    
    private func removeFooter()->UIView?
    {
        for view : AnyObject in scrollerView.subviews{
            if view is RefreshFooterView{
                view.removeFromSuperview()
                return view as? UIView
            }
        }
        return nil
    }
    
    
    private var headerBeginRefresh:Bool = false
    public func headerBeginRefreshing()
    {
        if(!headerBeginRefresh){
            headerBeginRefresh = true
            self.setNeedsLayout()
            //        headerView.beginRefreshing()
        }
    }
    
    public func headerIsRefreshing() -> Bool{
        return self.headerBeginRefresh
    }
    
    private var headerBeginRest:Bool = false
    public func headerReset()
    {
        footerReset()
        headerView?.reset()
        headerBeginRest = true
        self.setNeedsLayout()
    }
    
    public func footerBeginRefreshing()
    {
        footerView?.beginRefreshing()
    }
    
//    private var footerBeginRest:Bool = false
    public func footerReset(){
//        footerBeginRest = true
        footerView?.reset()
    }
    
    public func footerStraight(){
        footerView?.adjustStateWithContentOffset(true)
    }
    
    public func footerNodata(){
        footerView?.noDataRefreshing()
    }
}
