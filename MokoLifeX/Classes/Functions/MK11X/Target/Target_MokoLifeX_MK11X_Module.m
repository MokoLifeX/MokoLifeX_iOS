//
//  Target_MokoLifeX_MK11X_Module.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "Target_MokoLifeX_MK11X_Module.h"

#import "MKLFXBServerForDeviceController.h"

#import "MKLFXBSwitchStateController.h"

@implementation Target_MokoLifeX_MK11X_Module

- (UIViewController *)Action_MokoLifeX_MK11X_Module_ServerForDevicePage:(NSDictionary *)params {
    MKLFXBServerForDeviceController *vc = [[MKLFXBServerForDeviceController alloc] init];
    vc.deviceInfo = params;
    return vc;
}

/// 设备开关页面
/// @param params @{@"deviceModel":id <MKLFXDeviceModel *>deviceModel}
- (UIViewController *)Action_MokoLifeX_MK11X_Module_SwitchStatePage:(NSDictionary *)params {
    MKLFXBSwitchStateController *vc = [[MKLFXBSwitchStateController alloc] init];
    vc.deviceModel = params[@"deviceModel"];
    return vc;
}

@end
