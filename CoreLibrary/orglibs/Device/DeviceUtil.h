//
//  DeviceUtil.h
//  BestPalmPilot
//
//  Created by admin on 16/2/2.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sys/utsname.h"
#import "sys/sysctl.h"

@interface DeviceUtil : NSObject

/** 获取设备型号 */
+ (NSString *)getCurrentDeviceModel;

@end
