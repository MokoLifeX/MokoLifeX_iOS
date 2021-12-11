//
//  MKLFXElectricityController.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXElectricityController : MKLFXBaseController

/// 电能通知名称
@property (nonatomic, copy)NSString *electricityNotificationName;

/// 112/114设备上报的电压数据需要乘以0.1
@property (nonatomic, assign)float voltageCoffe;

@end

NS_ASSUME_NONNULL_END
