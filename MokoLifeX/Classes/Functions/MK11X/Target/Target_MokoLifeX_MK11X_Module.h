//
//  Target_MokoLifeX_MK11X_Module.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_MokoLifeX_MK11X_Module : NSObject

/// 设备MQTT服务器配置页面
/// @param params 详情看参数说明
/*
    @{
        @"device_name":@"MK10X",
        @"device_id":@"xxxxxxxxxxxx",
        @"device_type":@"1",
 }
 */
- (UIViewController *)Action_MokoLifeX_MK11X_Module_ServerForDevicePage:(NSDictionary *)params;

/// 设备开关页面
/// @param params @{@"deviceModel":id <MKLFXDeviceModel *>deviceModel}
- (UIViewController *)Action_MokoLifeX_MK11X_Module_SwitchStatePage:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
