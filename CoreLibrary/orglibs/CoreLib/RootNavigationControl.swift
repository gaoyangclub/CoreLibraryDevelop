//
//  HomePageControl.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/10/18.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

@objc public class RootNavigationControl: UINavigationController {

    public var navigationColor = UIColor(red: 232 / 255, green: 50 / 255, blue: 85 / 255, alpha: 0.5){
        didSet{
            self.navigationBar.barTintColor = navigationColor
        }
    }
    public var hairlineHidden:Bool = false
    
    private static var instance:RootNavigationControl!
    public static func getInstance()->RootNavigationControl{
        if instance == nil{
            instance = RootNavigationControl()
//            print("RootNavigationControl初始化单例")
        }
        return instance
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    public override func viewWillAppear(animated: Bool){
        self.navigationBar.translucent = false//    Bar的高斯模糊效果，默认为YES
        super.viewWillAppear(animated)
        self.navigationBar.barTintColor = navigationColor
        self.navBarHairlineImageView?.hidden = true
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navBarHairlineImageView?.hidden = false
    }
    
    private lazy var navBarHairlineImageView:UIImageView? = {
        if !self.hairlineHidden {
            return nil//不需要隐藏
        }
        let hailline = self.findHairlineImageViewUnder(self.navigationBar)
        return hailline
    }()//{// = [self findHairlineImageViewUnder:navigationBar];
    
    public override func viewDidLoad() {
//        hidesBottomBarWhenPushed = true
//        toolbarHidden = true
//        setNavigationBarHidden(false, animated: false)
//        setToolbarHidden(true, animated: false)
//        navigationBar.hidden = true
    }
    
    private func findHairlineImageViewUnder(view:UIView)->UIImageView?{
//        print("findHairline Height:\(view.bounds.size.height)")
        if (view is UIImageView && view.bounds.size.height <= 1.0) {
            return view as? UIImageView
        }
        for subview in view.subviews {
            let imageView:UIImageView? = self.findHairlineImageViewUnder(subview);
            if (imageView != nil) {
                return imageView
            }
        }
        return nil
    }

    

}
