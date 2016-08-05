//
//  BatchLoaderForSwift.swift
//  BatchLoaderTest
//
//  Created by admin on 16/2/3.
//  Copyright © 2016年 admin. All rights reserved.
//

import UIKit

public typealias LoadCompletionHandler = (image:UIImage?)->Void
private class LoaderVo:NSObject {
    var url:String
    var callBack:LoadCompletionHandler?
//    var argArray:[AnyObject]
    
    init(_ url:String,_ callBack:LoadCompletionHandler?){
        self.url = url
        self.callBack = callBack
//        self.argArray = argArray
    }
}
public class BatchLoaderForSwift: UIControl {

//    private static var instance:BatchLoaderForSwift!
//    class func sharedLoader()->BatchLoaderForSwift{
//        if instance == nil{
//            instance = BatchLoaderForSwift()
//        }
//        return instance
//    }
    
    public class func loadFile(url:String,callBack:LoadCompletionHandler?){
        let image = BatchLoaderForOC.getImageCacheByUrl(url)
        if image != nil{
            callBack?(image: image);//直接回调
            return
        }
        var paraArray:NSMutableArray? = callBackDic[url]
        var startLoad:Bool = false
        if  paraArray == nil{//不存在
            paraArray = NSMutableArray() //创建空的数组
            callBackDic.updateValue(paraArray!, forKey: url)//混存数组
            startLoad = true //可以开始加载
        }
        paraArray?.addObject(LoaderVo(url,callBack)) //存入回调
        if startLoad{ //可以加载
            BatchLoaderForOC.loadFile(url, target: BatchLoaderForSwift.self, andSelection: "loadFileComplete:")
        }
    }
    
    private static var callBackDic:Dictionary<String,NSMutableArray> = Dictionary<String,NSMutableArray>()
    class func loadFileComplete(info:FileInfo){////url:String, withObject image:UIImage?
//        print("加载成功  \(info.url)  \(info.image)")
//        dispatch_async(dispatch_get_main_queue(),{//通知主线程刷新 神坑 异步加载完毕的数据在其他线程上 必须通知主线程刷新调用逻辑
            var paraArray:NSMutableArray? = BatchLoaderForSwift.callBackDic[info.url]
            BatchLoaderForSwift.callBackDic.removeValueForKey(info.url) //清除掉数据
            if paraArray != nil{
                for para in paraArray!{ //遍历后依次回调
                    let loaderVo = (para as! LoaderVo)
                    if let handler = loaderVo.callBack {
                        handler(image: info.image)
                    }
                }
            }
            paraArray = nil //释放
//        })
    }



}
