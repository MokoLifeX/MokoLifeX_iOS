//
//  Target_MokoLifeX_MK10X_Module.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "Target_MokoLifeX_MK10X_Module.h"

#import "MKLFXAServerForDeviceController.h"

#import "MKLFXASwitchStateController.h"

@implementation Target_MokoLifeX_MK10X_Module

- (UIViewController *)Action_MokoLifeX_MK10X_Module_ServerForDevicePage:(NSDictionary *)params {
    MKLFXAServerForDeviceController *vc = [[MKLFXAServerForDeviceController alloc] init];
    vc.deviceInfo = params;
    return vc;
}

/// 设备开关页面
/// @param params @{@"deviceModel":id <MKLFXDeviceModel *>deviceModel}
- (UIViewController *)Action_MokoLifeX_MK10X_Module_SwitchStatePage:(NSDictionary *)params {
    MKLFXASwitchStateController *vc = [[MKLFXASwitchStateController alloc] init];
    vc.deviceModel = params[@"deviceModel"];
    return vc;
}

@end
