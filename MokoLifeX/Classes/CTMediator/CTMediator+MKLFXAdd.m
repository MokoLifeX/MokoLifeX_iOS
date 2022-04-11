//
//  CTMediator+MKLFXAdd.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "CTMediator+MKLFXAdd.h"

#import "MKMacroDefines.h"

#import "MKLFXDeviceModel.h"

#import "MKMokoLifeXModuleKey.h"

@implementation CTMediator (MKLFXAdd)

- (UIViewController *)CTMediator_MokoLifeX_ServerForDevicePage:(NSDictionary *)params {
    NSInteger deviceType = [params[@"device_type"] integerValue];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    if (deviceType == 0 || deviceType == 1) {
        //MK102、MK112、MK114
        NSString *deviceID = params[@"device_id"];
        NSString *deviceName = params[@"device_name"];
        NSString *tempID = [deviceID substringFromIndex:8];
        NSString *name = [NSString stringWithFormat:@"%@-%@",deviceName,tempID];
        [dic setObject:name forKey:@"device_name"];
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK10X_module
                                                        action:kAction_MokoLifeX_MK10X_serverForDevicePage
                                                        params:dic];
    }
    if (deviceType == 2 || deviceType == 3) {
        //MK115、MK116
        NSString *deviceID = params[@"device_id"];
        NSString *deviceName = params[@"device_name"];
        NSString *tempID = [deviceID substringFromIndex:8];
        NSString *name = [NSString stringWithFormat:@"%@-%@",deviceName,tempID];
        [dic setObject:name forKey:@"device_name"];
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK11X_module
                                                        action:kAction_MokoLifeX_MK11X_serverForDevicePage
                                                        params:dic];
    }
    if (deviceType == 4) {
        //MK117
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK117_module
                                                        action:kAction_MokoLifeX_MK117_serverForDevicePage
                                                        params:params];
    }
    if (deviceType == 5) {
        //MK117D
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK117_module
                                                        action:kAction_MokoLifeX_MK117_117DserverForDevicePage
                                                        params:params];
    }
    return [[UIViewController alloc] init];
}

- (UIViewController *)CTMediator_MokoLifeX_SwitchStatePage:(MKLFXDeviceModel *)deviceModel {
    if (!deviceModel || ![deviceModel isKindOfClass:MKLFXDeviceModel.class]) {
        return [[UIViewController alloc] init];
    }
    NSInteger type = [deviceModel.deviceType integerValue];
    if (type == 0 || type == 1) {
        //MK102、MK112、MK114
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK10X_module
                                                        action:kAction_MokoLifeX_MK10X_switchStatePage
                                                        params:@{@"deviceModel":deviceModel}];
    }
    if (type == 2 || type == 3) {
        //MK115、MK116
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK11X_module
                                                        action:kAction_MokoLifeX_MK11X_switchStatePage
                                                        params:@{@"deviceModel":deviceModel}];
    }
    if (type == 4 || type == 5) {
        //MK117、MK117D
        return [self Action_MokoLifeX_ViewControllerWithTarget:kTarget_MokoLifeX_MK117_module
                                                        action:kAction_MokoLifeX_MK117_switchStatePage
                                                        params:@{@"deviceModel":deviceModel}];
    }
    return [[UIViewController alloc] init];
}

#pragma mark - private method
- (UIViewController *)Action_MokoLifeX_ViewControllerWithTarget:(NSString *)targetName
                                                         action:(NSString *)actionName
                                                         params:(NSDictionary *)params{
    UIViewController *viewController = [self performTarget:targetName
                                                    action:actionName
                                                    params:params
                                         shouldCacheTarget:NO];
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[UIViewController alloc] init];
    }
}

@end
