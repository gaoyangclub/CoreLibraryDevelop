//
//  FundPageDrawerController.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/12/31.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

@objc public class RootDrawerController: MMDrawerController {
    
    private static var instance:MMDrawerController!
    public static func getInstance()->MMDrawerController{
        if instance == nil{
            instance = MMDrawerController()
        }
        return instance
    }

//    private func initTitleView(){
//        //        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
//        let leftItem = //UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "cancelClick")
//        UIBarButtonItem(title: "嘿嘿", style: UIBarButtonItemStyle.Done, target: self, action: "cancelClick")
//        let customView = UIArrowView(frame:CGRectMake(0, 0, 10, 22))
//        customView.direction = .LEFT
//        customView.lineColor = UIColor.whiteColor()
//        customView.lineThinkness = 2
//        leftItem.customView = customView
//        customView.addTarget(self, action: "cancelClick", forControlEvents: UIControlEvents.TouchDown)
//        
//        let tabItem = UIFlatImageTabItem()
//        tabItem.frame = CGRectMake(0, 0, 30, 24)
//        tabItem.sizeType = .FillWidth
//        tabItem.normalColor = UIColor.whiteColor()
//        //        tabItem.selectColor = UICreaterUtils.colorRise
//        BatchLoaderUtil.loadFile("magnifie", callBack: { (image, params) -> Void in
//            tabItem.image = image
//        })
//        tabItem.addTarget(self, action: "searchClick", forControlEvents: UIControlEvents.TouchDown)
//        let rightItem =
//        UIBarButtonItem(title: "嘿嘿", style: UIBarButtonItemStyle.Done, target: self, action: "searchClick")
//        rightItem.customView = tabItem
//        
//        self.navigationItem.leftBarButtonItem = leftItem
//        self.navigationItem.rightBarButtonItem = rightItem
//        self.title = "基金筛选"
//        
////        self.view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
//        
//        let titleView = UIView()
//        let label:UILabel = UICreaterUtils.createLabel(20, UIColor.whiteColor(), "基金筛选", true, titleView)
//        label.font = UIFont.systemFontOfSize(20)//20号,weight:2
//        
//        titleView.addSubview(label)
//        label.snp_makeConstraints { (make) -> Void in
//            make.center.equalTo(titleView)
//        }
//        
//        self.navigationItem.titleView = titleView
//        
////        self.view.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1)
//    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
//        initTitleView()
        
//        self.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.None
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pushView:", name: "FundFilter:pushView",object:nil)
        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func cancelClick(){
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    func searchClick(){
//        self.toggleDrawerSide(MMDrawerSide.Right, animated: true, completion: { _ -> Void in
//            
//        })
////        self.navigationController?.pushViewController(SearchViewController(), animated: true)
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
