//
//  Target_MokoLifeX_MK117_Module.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_MokoLifeX_MK117_Module : NSObject

/// MK117设备MQTT服务器配置页面
/// @param params 详情看参数说明
/*
    @{
    @"device_name":@"MK10X",
    @"device_id":@"xxxxxxxxxxxx",
    @"device_type":@"4",
 }
 */
- (UIViewController *)Action_MokoLifeX_MK117_Module_ServerForDevicePage:(NSDictionary *)params;

/// 设备开关页面
/// @param params @{@"deviceModel":id <MKLFXDeviceModel *>deviceModel}
- (UIViewController *)Action_MokoLifeX_MK117_Module_SwitchStatePage:(NSDictionary *)params;

/// MK117D设备MQTT服务器配置页面
/// @param params 详情看参数说明
/*
    @{
    @"device_name":@"MK10X",
    @"device_id":@"xxxxxxxxxxxx",
    @"device_type":@"5",
 }
 */
- (UIViewController *)Action_MokoLifeX_MK117_Module_117DServerForDevicePage:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
