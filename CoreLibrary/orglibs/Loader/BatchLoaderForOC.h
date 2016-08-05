//
//  BatchLoaderForOC.h
//  BatchLoaderTest
//
//  Created by admin on 16/2/3.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileInfo.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

typedef void (^LoadCompletionHandler)(UIImage*);//定义block结构
//@interface FileInfo: NSObject
//
//
//@end

//typedef struct {
//__unsafe_unretained NSString * url;
//__unsafe_unretained UIImage * image;
//}FileInfo;

@interface BatchLoaderForOC : NSObject

+(void)loadFile:(NSString*)url _:(LoadCompletionHandler)callBack;
+(void)loadFile:(NSString*)url target:(id)target andSelection:(SEL)action;
+(UIImage*)getImageCacheByUrl:(NSString*)url;

@end
