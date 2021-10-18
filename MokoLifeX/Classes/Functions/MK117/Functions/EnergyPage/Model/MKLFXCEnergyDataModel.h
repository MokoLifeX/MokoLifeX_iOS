//
//  MKLFXCEnergyDataModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCEnergyDataModel : NSObject

/// 日均数据读取是否成功
@property (nonatomic, assign)BOOL dailySuccess;

/// 历史数据是否成功
@property (nonatomic, assign)BOOL monthSuccess;

/// 脉冲场数持否成功
@property (nonatomic, assign)BOOL pulseSuccess;

/// 累计总电能是否成功
@property (nonatomic, assign)BOOL totalSuccess;

/// 日均数据(里面包含每小时)
@property (nonatomic, strong)NSArray *dailyList;

/// 月均数据(里面包含每天，从最新时间开始往前推29天)
@property (nonatomic, strong)NSArray *monthlyList;

/// 脉冲常数
@property (nonatomic, copy)NSString *pulseConstant;

/// 总的累计电能数据
@property (nonatomic, copy)NSString *totalEnergy;

/// 当天电能数据的时间戳,yyyy-MM-dd
@property (nonatomic, copy)NSString *timestampOfToday;

/// 历史每天累计电能开始时间戳,yyyy-MM-dd
@property (nonatomic, copy)NSString *timestampOfStartHistory;

/// 历史每天累计电能结束时间戳,yyyy-MM-dd
@property (nonatomic, copy)NSString *timestampOfEndHistory;

- (BOOL)success;

+ (NSArray *)parseMonthList:(NSString *)timestamp dataList:(NSArray *)dataList;

+ (NSArray *)parseDaily:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
