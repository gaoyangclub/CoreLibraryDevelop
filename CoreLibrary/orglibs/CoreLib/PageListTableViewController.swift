//
//  PageListTableViewController.swift
//  BestPalmPilot
//
//  Created by admin on 16/1/18.
//  Copyright © 2016年 admin. All rights reserved.
//

import UIKit

public class PageListTableViewController: BaseTableViewController {

    public var pageSO:PageListSO?// = self.createPageSO()
    public var hasSetUp:Bool = false
    public var showHeader:Bool = true
    public var showFooter:Bool = true
    public var hasFirstRefreshed:Bool = false //第一次刷新界面
    public var sectionGap:CGFloat = 0 //每一节间隔
    public var cellGap:CGFloat = 0 //每个条目间隔
    
    public override func loadView() {
        super.loadView()
        pageSO = createPageSO()
    }
    
    public func createPageSO()->PageListSO{
        return PageListSO()
    }
    
    /** 头部下拉全部刷新 */
    public func headerRequest(pageSO:PageListSO?,callback:((hasData:Bool,sorttime:String) -> Void)!){
        
    }
    
    /** 底部上拉刷新 */
    public func footerRequest(pageSO:PageListSO?,callback:((hasData:Bool,sorttime:String) -> Void)!){
        
    }
    
    public func pureTable()->Bool{
        return false
    }
    
    public func setupRefresh(){
        self.hasSetUp = true
        
        if pureTable(){ //纯净无刷新功能列表
            showHeader = false
            showFooter = false
            self.tableView?.reloadData()
        }
        
        if showHeader{
            self.refreshContaner.addHeaderWithCallback(RefreshHeaderView.header(),callback: { [weak self] ()-> Void in
                //            self?.pageSO?.pagenumber = PageListSO.firstPageNumber//重新清零
                self?.pageSO?.sorttime = ""
                
                self?.headerRequest((self!.pageSO)){ [weak self] hasData,lastUpdateTime in//获取数据完毕 刷新界面
                    self?.pageSO?.sorttime = lastUpdateTime
                    self?.hasFirstRefreshed = true
                    self?.checkGaps()
                    
                    self?.tableView?.reloadData()
                    if hasData {
                        self?.refreshContaner?.headerReset()
                    }else{
                        self?.refreshContaner?.headerReset()
                        self?.refreshContaner?.footerNodata()
                        //                    self?.pageSO?.pagenumber = PageListSO.firstPageNumber //清空页数
                        self?.pageSO?.sorttime = ""
                    }
                }
            })
        }
        
        if showFooter {
            self.refreshContaner.addFooterWithCallback(RefreshFooterView.footer(),callback: { [weak self] ()-> Void in
//                let nowPage = self?.pageSO?.pagenumber
//                self?.pageSO?.pagenumber += 1//页数+1
                
                self?.footerRequest(self!.pageSO){ [weak self] hasData,lastUpdateTime in
                    self?.pageSO?.sorttime = lastUpdateTime
                    if hasData {
                        self?.checkGaps()
                        
                        self?.tableView?.reloadData()
                        self?.refreshContaner?.footerReset()
                    }else{
                        self?.refreshContaner?.footerNodata()
//                        self?.pageSO?.pagenumber = nowPage! //页数恢复
                    }
                }
            })
        }
    }
    
    //检查数据间隔
    public func checkGaps(){
        //遍历整个数据链 判断头尾标记和gap是否存在
        for i in 0..<dataSource.count{
            let svo:SourceVo = dataSource[i] as! SourceVo
//            var preCellVo:CellVo? = nil
            if svo.data != nil && svo.data?.count > 0{
                var hasFirst:Bool = false
                var hasLast:Bool = false
                for(var j = svo.data!.count - 1; j >= 0 ; j--) {//倒序遍历 有可能会有删除工作
                    let cvo:CellVo = svo.data![j] as! CellVo
                    if cvo.cellTag == CellVo.CELL_TAG_FIRST {
                        hasFirst = true
                    }else if cvo.cellTag == CellVo.CELL_TAG_LAST {
                        hasLast = true
                    }else if cvo.cellTag == CellVo.CELL_TAG_SECTION_GAP {
//                        if sectionGap <= 0{//已经不需要
                            svo.data?.removeObjectAtIndex(j) //先全部清除
//                            continue
//                        }
                    }else if cvo.cellTag == CellVo.CELL_TAG_CELL_GAP {
//                        if cellGap <= 0{//已经不需要
                            svo.data?.removeObjectAtIndex(j) //先全部清除
//                            continue
//                        }
                    }
//                    preCellVo = cvo
                }
                if !hasFirst {//不存在
                    (svo.data![0] as! CellVo).cellTag = CellVo.CELL_TAG_FIRST //标记第一个就是
                }
                if !hasLast {
                    (svo.data![svo.data!.count - 1] as! CellVo).cellTag = CellVo.CELL_TAG_LAST //标记最后一个就是
                }
            }
        }
        
        if sectionGap > 0 || cellGap > 0{
            for i in 0..<dataSource.count{
                let svo:SourceVo = dataSource[i] as! SourceVo
                //            var preCellVo:CellVo? = nil
                if svo.data != nil && svo.data?.count > 0{
                    for(var j = svo.data!.count - 1; j >= 0 ; j--) {//倒序遍历 有可能会有删除工作
                        if sectionGap > 0 && j == svo.data!.count - 1 && i != dataSource.count - 1{//非最后一节 且最后一个实体存到最后
                            svo.data?.addObject(getSectionGapCellVo())
                        }else if cellGap > 0 && j != svo.data!.count - 1{//不是最后一个直接插入
                            svo.data?.insertObject(getCellGapCellVo(), atIndex: j + 1)
                        }
                    }
                }
            }
//            if cvo.cellTag == CellVo.CELL_TAG_SECTION_GAP { //节gap
//                if preCellVo != nil && preCellVo!.isRealCell() {//前一个是真实数据
//                    svo.data?.insertObject(getSectionGapCellVo(), atIndex: j)
//                }else if preCellVo != nil && !preCellVo!.isRealCell() {//前一个是gap
//                }
//            }
        }
        
    }
    
    private func getSectionGapCellVo()->CellVo{
        return CellVo(cellHeight: sectionGap, cellClass: BaseTableViewCell.self,cellData:nil,cellTag:CellVo.CELL_TAG_SECTION_GAP)
    }
    private func getCellGapCellVo()->CellVo{
        return CellVo(cellHeight: cellGap, cellClass: BaseTableViewCell.self,cellData:nil,cellTag:CellVo.CELL_TAG_CELL_GAP)
    }
    
    /** 滚轮是否恢复位置 */
    public var contentOffsetRest:Bool = true
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if hasSetUp {
            if contentOffsetRest{
                self.refreshContaner.scrollerView.contentOffset.y = 0 //滚轮位置恢复
            }
        }else{
            self.setupRefresh()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
public class PageListSO:NSObject{
    
    static let firstPageNumber:Int = 1
    
    public var objectsperpage:Int = 20 //每页显示20个
//    var pagenumber:Int = firstPageNumber//当前页码
//    var lastupdatetime:String = ""//年月日 时分秒
    public var sorttime:String = "" //排序专用
    
}
