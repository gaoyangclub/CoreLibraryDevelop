//
//  BaseTableViewCell.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/10/29.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class BaseTableViewCell: UITableViewCell {

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
    
    required public override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public var indexPath:NSIndexPath = NSIndexPath(){
        didSet{
            setNeedsLayout()
        }
    }
    
    public var isFirst:Bool = false
    public var isLast:Bool = false
    
    public var needRefresh:Bool = true //默认需要刷新
    
    public var tableView:UITableView?{
        didSet{
            setNeedsLayout()
        }
    }
    
    public var autoCellHeight:Bool = true
    
    public var cellVo:CellVo?{
        didSet{
//            if(self.cellVo != nil && self.cellVo!.cellHeight <= 1){//高度自适应
////            if(autoCellHeight){
//                showSubviews()
//                self.setNeedsLayout()
//                self.layoutIfNeeded()//强制刷新
//                self.layoutIfNeeded()//强制刷新
//                self.cellVo?.cellHeight = getCellHeight()
//            }else{
                setNeedsLayout()
//            }
        }
    }
    
    public func getCellHeight()->CGFloat{
        return 0
    }
    
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
    
    public override func layoutSubviews(){
        super.layoutSubviews()
        if needRefresh {
            showSubviews()
        }
    }
    
    public func showSubviews(){
        //具体实现视图都在这里
    }
    
    
}
