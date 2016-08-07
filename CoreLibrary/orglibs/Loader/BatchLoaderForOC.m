//
//  BatchLoaderForOC.m
//  BatchLoaderTest
//
//  Created by admin on 16/2/3.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "BatchLoaderForOC.h"

@implementation BatchLoaderForOC

//NSMutableDictionary<NSString*,ActionVo*>* actionDic;
//NSMutableDictionary<NSString*,NSMutableArray*>* dic;// = [[NSMutableDictionary alloc]init];

NSMutableDictionary<NSString*,UIImage*>* imageCacheDic;
NSMutableDictionary<NSString*,NSMutableArray*>* callBackDic;

+(void)loadFile:(NSString*)url _:(LoadCompletionHandler)callBack {
    UIImage* image = [BatchLoaderForOC getImageCacheByUrl:url];
    if(image != NULL){
        callBack(image);//直接回调
        return;
    }
    //开始存储回调队列
    if(callBackDic == NULL){
        callBackDic = [[NSMutableDictionary alloc]init];
    }
    NSMutableArray* paraArray = [callBackDic objectForKey:url];
    BOOL startLoad = NO;
    if(paraArray == NULL){//不存在
        paraArray = [[NSMutableArray alloc]init]; //创建空的数组
        [callBackDic setObject:paraArray forKey:url];//混存数组
        startLoad = YES; //可以开始加载
    }
    [paraArray addObject:callBack];//存入回调
    if(startLoad){
        [BatchLoaderForOC loadFile:url target:[self class] andSelection:@selector(loadFileComplete:)];
    }
}

+(void)loadFileComplete:(FileInfo*)info{////url:String, withObject image:UIImage?
    NSMutableArray* paraArray = [callBackDic objectForKey:info.url];
    [callBackDic removeObjectForKey:info.url];//清除掉数据
    if(paraArray != NULL){
        for (LoadCompletionHandler callBack in paraArray) {
            callBack(info.image);//直接回调
        }
    }
    paraArray = NULL;//释放
}


+(void)loadFile:(NSString*)url target:(id)target andSelection:(SEL)action { //_:(LoadCompletionHandler*)callBack;
    if(imageCacheDic == NULL){
        imageCacheDic = [[NSMutableDictionary alloc]init];
    }
    UIImage* image = [imageCacheDic objectForKey:url];
    if(image != NULL){
        [BatchLoaderForOC sendActionByUrl:target andSelection:action andUrl:url andImage:image];//直接回调
        return;
    }
    NSRange range = [url rangeOfString:@"://"];
    if (range.length > 0){//包含 属于网络类型数据
        [BatchLoaderForOC loadStart:url target:target andSelection:action];//开始加载
    }else{
        image = [UIImage imageNamed:url];
        [BatchLoaderForOC sendActionByUrl:target andSelection:action andUrl:url andImage:image];//本地调用
        image != NULL ? [imageCacheDic setObject:image forKey:url] : "";//存入缓存
    }
}

+(void)loadStart:(NSString*)url target:(id)target andSelection:(SEL)action{
    NSURL *nsurl = [NSURL URLWithString:url];
    NSURLRequest* req = [NSURLRequest requestWithURL:nsurl];//
    //    [nsurl startAccessingSecurityScopedResource];
    //    [[NSURLSession sharedSession]dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse *         _Nullable response, NSError * _Nullable error) {
    //        UIImage* image = [[UIImage alloc]initWithData:data];
    //        [BatchLoaderForOC sendActionByUrl:target andSelection:action andUrl:url andImage:image];//回调
    //        [imageCacheDic setObject:image forKey:url];//存入缓存
    //    }];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {//该方法在IOS9以上被淘汰
         if(connectionError){
             //             printf(connectionError);
             return;
         }
         dispatch_async(dispatch_get_main_queue(), ^{//直接主线程
             UIImage* image = [UIImage imageWithData:data];
             [BatchLoaderForOC sendActionByUrl:target andSelection:action andUrl:url andImage:image];//回调
             [imageCacheDic setObject:image forKey:url];//存入缓存
             //             [nsurl stopAccessingSecurityScopedResource];
         });
     }];
}

+(UIImage* _Nullable)getImageCacheByUrl:(NSString*)url{
    if(imageCacheDic == NULL)return NULL;
    return [imageCacheDic objectForKey:url];
}

+(void)sendActionByUrl:(id)target andSelection:(SEL)action andUrl:(NSString*)url andImage:(UIImage*)image{
    if(action != NULL){
        FileInfo* info = [[FileInfo alloc]init];
        info.url = url;
        info.image = image;
        //            objc_msgSend(_target,_selAction,[NSNumber numberWithInteger:selectedIndex],selectedIndex);
        SuppressPerformSelectorLeakWarning(
                                           [target performSelector:action withObject:info];//afterDelay:0
        );
        //        [target performSelector:action withObject:image];
    }
}

@end
