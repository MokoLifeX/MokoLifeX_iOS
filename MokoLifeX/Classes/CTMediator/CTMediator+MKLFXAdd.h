//
//  CTMediator+MKLFXAdd.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <CTMediator/CTMediator.h>

NS_ASSUME_NONNULL_BEGIN

@class MKLFXDeviceModel;
@interface CTMediator (MKLFXAdd)

/// 设备MQTT服务器设置页面
/// @param params 看参数说明
/*
    参数说明
 @{
    @"device_name":@"MK10X",
    @"device_id":@"xxxxxxxxxxxx",
    @"device_type":@"1",
 }
 */
- (UIViewController *)CTMediator_MokoLifeX_ServerForDevicePage:(NSDictionary *)params;

/// 设备开关页面
/// @param deviceModel deviceModel
/*
    注意，deviceModel中包含设备类型0/1(MK102、MK112、MK114)     2(MK115)   3(MK116)    4(MK117)   5(MK117D)
 */
- (UIViewController *)CTMediator_MokoLifeX_SwitchStatePage:(MKLFXDeviceModel *)deviceModel;

@end

NS_ASSUME_NONNULL_END
