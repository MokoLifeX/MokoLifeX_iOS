//
//  MKLFXBEnergyDailyTableView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBEnergyDailyTableView : UIView

/// 初始化
/// @param deviceID deviceID
/// @param name 当前电能数据通知名称
- (instancetype)initWithDeviceID:(NSString *)deviceID currentEnergyNotificationName:(NSString *)name;

/// 更新列表
/// @param energyList 转数数据
/// @param pulseConstant 脉冲常数
- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant;

/// 用户重置了电能
- (void)resetAllDatas;

@end

NS_ASSUME_NONNULL_END
