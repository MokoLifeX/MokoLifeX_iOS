//
//  Target_MokoLifeX_MK117_Module.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "Target_MokoLifeX_MK117_Module.h"

#import "MKLFXCServerForDeviceController.h"

#import "MKLFXCSwitchStateController.h"

@implementation Target_MokoLifeX_MK117_Module

- (UIViewController *)Action_MokoLifeX_MK117_Module_ServerForDevicePage:(NSDictionary *)params {
    MKLFXCServerForDeviceController *vc = [[MKLFXCServerForDeviceController alloc] init];
    vc.deviceInfo = params;
    return vc;
}

/// 设备开关页面
/// @param params @{@"deviceModel":id <MKLFXDeviceModel *>deviceModel}
- (UIViewController *)Action_MokoLifeX_MK117_Module_SwitchStatePage:(NSDictionary *)params {
    MKLFXCSwitchStateController *vc = [[MKLFXCSwitchStateController alloc] init];
    vc.deviceModel = params[@"deviceModel"];
    return vc;
}

@end
