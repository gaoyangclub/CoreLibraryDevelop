//
//  BaseTableViewController.swift
//  FinanceApplicationTest
//
//  Created by 高扬 on 15/11/1.
//  Copyright (c) 2015年 高扬. All rights reserved.
//

import UIKit

public class BaseTableViewController: RefreshTableViewController {

    public var refreshAll:Bool = true
    public var dataSource:NSMutableArray=[]//二维数组 [section][index]
    
    /** 重新刷新界面 */
    public func refreshHeader(){
        if(!self.refreshContaner.headerIsRefreshing()){//不在刷新状态下可以继续
            self.dataSource.removeAllObjects()
            self.tableView.reloadData()//强制刷新 解决条目数量已经超过可视区域 刷新头部无下拉效果问题
            self.refreshContaner.headerBeginRefreshing()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //种类个数
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let source = dataSource[section] as! SourceVo
        return source.headerHeight
    }
    
    private lazy var nsSectionDic:Dictionary<Int,BaseItemRenderer> = [:]
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let source = dataSource[section] as! SourceVo
        let headerClass = source.headerClass
        var headerView = nsSectionDic[section]
        if headerView == nil{
            if(headerClass != nil){
                headerView = headerClass!.init()
                nsSectionDic.updateValue(headerView!, forKey: section)
            }
        }
        headerView!.itemIndex = section
        headerView!.data = source.headerData
        return headerView
    }
    
//    private var autoCellInstance:BaseTableViewCell? = nil
    public var autoCellClass:BaseTableViewCell.Type?{
        didSet{
//            autoCellInstance = autoCellClass?.init(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
            if autoCellClass != nil{
                let classString:String = NSStringFromClass(self.autoCellClass!)
                self.tableView?.registerClass(autoCellClass.self, forCellReuseIdentifier: classString)
            }
        }
    }
    
    //每个Cell高度
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = indexPath.section
        let source = dataSource[section] as! SourceVo
        let cellVo:CellVo = source.data![indexPath.row] as! CellVo
//        if(cell.cellHeight <= 1){//自动填充高度
//            // 返回计算出的cell高度（普通简化版方法，同样只需一步设置即可完成）
////            return [self.tv cellHeightForIndexPath:indexPath model:threeModel keyPath:@"threeModel" cellClass:mClass contentViewWidth:[self cellContentViewWith]];
//            
////            let cellHeight = self.tableView.cellHeightForIndexPath(indexPath, model: cell.cellData as! AnyObject, keyPath: "cellData", cellClass: cell.cellClass, contentViewWidth: self.cellContentViewWith())
//            let cellHeight = self.tableView.cellHeightForIndexPath(indexPath, cellContentViewWidth:self.cellContentViewWith(), tableView: self.tableView)
//            return cellHeight
//        }
//        print("高度测量 heightForRowAtIndexPath:\(cell.cellHeight)  row位置:\(indexPath.row)")
//        if(autoCellInstance != nil){
//            autoCellInstance?.cellVo = cellVo
//            autoCellInstance?.indexPath = indexPath
////            cell!.tableView = tableView
//            autoCellInstance?.data = cellVo.cellData
//            autoCellInstance?.showSubviews()
//            autoCellInstance?.layoutIfNeeded()//强制刷新
//            autoCellInstance?.updateConstraintsIfNeeded();
//            return autoCellInstance!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
////            CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
////            return autoCellInstance!.getCellHeight()
//        }
        if autoCellClass != nil{
            let classString:String = NSStringFromClass(self.autoCellClass!)
            return tableView.fd_heightForCellWithIdentifier(classString) { cellView -> Void in
                if cellView is BaseTableViewCell{
                    let cell = cellView as! BaseTableViewCell
                    cell.cellVo = cellVo
                    cell.indexPath = indexPath
                    cell.data = cellVo.cellData
                    cell.showSubviews()//强制刷新
                }
            }
        }
        return cellVo.cellHeight//source.sourceHeight
    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        if cell != nil{
//            return cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 1
//        }
//        return 1
//    }
    
    //获取容器宽度 方便重写
    func cellContentViewWith()->CGFloat
    {
        var width:CGFloat = UIScreen.mainScreen().bounds.size.width;
        // 适配ios7
        let version = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
        if (UIApplication.sharedApplication().statusBarOrientation != UIInterfaceOrientation.Portrait && version < 8) {
            width = UIScreen.mainScreen().bounds.size.height;
        }
        return width;
    }
    
    //种类对应条目个数
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let source = dataSource[section] as! SourceVo
        return source.data?.count ?? 0
        //tableView.numberOfRowsInSection(section)
    }
    public var useCellIdentifer:Bool = true
    //创建条目
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let section = indexPath.section
        let row = indexPath.row
        
        if(section >= dataSource.count){
            print("产生无效UITableViewCell 可能是一个刷新列表正在进行中 另一个刷新就来了引起的")
            return UITableViewCell()
        }
        
        let source = dataSource[section] as! SourceVo
        let cellVo:CellVo = source.data![row] as! CellVo//获取的数据给cell显示
        var cellClass = cellVo.cellClass
        if(autoCellClass != nil){
            cellClass = autoCellClass!
        }
        
        var cell:BaseTableViewCell?
        var isCreate:Bool = false
        if useCellIdentifer {
            var cellIdentifer:String!
            let classString:String = NSStringFromClass(cellClass)
            if cellVo.isUnique {//唯一
                cellIdentifer = classString + "_\(section)_\(row)"
            }else{
                cellIdentifer = classString
            }
            //        println("className:" + className)
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifer) as? BaseTableViewCell
            if cell == nil{
                cell = cellClass.init(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifer)
                isCreate = true
            }
        }else{
            cell = cellClass.init()
            isCreate = true
        }
//        else{
//            println("重用cell 类型:" + cellIdentifer)
//        }
        if isCreate{ //创建阶段设置
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cell!.backgroundColor = UIColor.clearColor()//无色
        }
        if !refreshAll && !isCreate{//上啦刷新且非创建阶段
            cell?.needRefresh = false //不需要刷新
            return cell! //直接返回无需设置
        }else{
            cell?.needRefresh = true //需要刷新
        }
        let data: Any? = cellVo.cellData
        cell!.isFirst = cellVo.cellTag == CellVo.CELL_TAG_FIRST//row == 0
        if source.data != nil{
            cell!.isLast = cellVo.cellTag == CellVo.CELL_TAG_LAST//row == source.data!.count - 1//索引在最后
        }
//        if(cellVo.cellTag > 0){
//            cell!.isFirst = cellVo.cellTag == CellVo.CELL_TAG_FIRST//row == 0
//            if source.data != nil{
//                cell!.isLast = cellVo.cellTag == CellVo.CELL_TAG_LAST//row == source.data!.count - 1//索引在最后
//            }
//        }else{
//            cell!.isFirst = row == 0 //最前
//            if source.data != nil{
//                cell!.isLast = row == source.data!.count - 1//索引在最后
//            }
//        }
        cell!.indexPath = indexPath
        cell!.tableView = tableView
        cell!.data = data
        cell!.cellVo = cellVo
        
//        print("cell创建 row位置:\(indexPath.row)")
        return cell!//tableView.cellForRowAtIndexPath(indexPath)!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
public class SourceVo{
    public init(data:NSMutableArray?,headerHeight:CGFloat = 0,headerClass:BaseItemRenderer.Type? = nil,headerData:Any? = nil,isUnique:Bool = false){
        //        sourceHeight:CGFloat,cellClass:BaseTableViewCell.Type,data:NSMutableArray?,
        //        self.sourceHeight = sourceHeight
        //        self.cellClass = cellClass
        self.headerHeight = headerHeight
        self.headerClass = headerClass
        self.headerData = headerData
        self.data = data
        self.isUnique = isUnique
    }
    //    var sourceHeight:CGFloat = 0.0
    //    var cellClass:BaseTableViewCell.Type
    public var data:NSMutableArray?//数据源
    public var headerHeight:CGFloat = 0.0
    public var headerClass:BaseItemRenderer.Type?
    public var headerData:Any?//标题的数据源
    public var isUnique:Bool = false
}
public class CellVo{
    
    public static let CELL_TAG_NORMAL:Int = 0 //中间的
    public static let CELL_TAG_FIRST:Int = 1 //第一个
    public static let CELL_TAG_LAST:Int = 2 //小组最后一个
    
    
    static let CELL_TAG_SECTION_GAP:Int = 10 //section的gap
    static let CELL_TAG_CELL_GAP:Int = 11 //cell的gap
    
    public init(cellHeight:CGFloat = 1,cellClass:BaseTableViewCell.Type,cellData:Any? = nil,cellTag:Int = 0,isUnique:Bool = false){
        self.cellHeight = cellHeight
        self.cellClass = cellClass
        self.cellData = cellData
        self.cellTag = cellTag
        self.isUnique = isUnique
    }
    public var cellHeight:CGFloat = 1 //高度不设置默认为自适应
    public var cellClass:BaseTableViewCell.Type
    public var cellData:Any?//栏目的数据源
    public var cellTag:Int = 0//1,2
    public var isUnique:Bool = false
    
    //是否是真实数据
    public func isRealCell()->Bool{
        return self.cellTag == CellVo.CELL_TAG_NORMAL || self.cellTag == CellVo.CELL_TAG_FIRST || self.cellTag == CellVo.CELL_TAG_LAST
    }
    
}
