//
//  MKEnergyDailyTableView.h
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKEnergyDailyTableView : UIView

/// 更新列表
/// @param energyList 转数数据
/// @param pulseConstant 脉冲常数
- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant;

/// 用户重置了电能
- (void)resetAllDatas;

@end

NS_ASSUME_NONNULL_END
