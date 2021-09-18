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

@property (nonatomic, assign)BOOL dailySuccess;

@property (nonatomic, assign)BOOL monthSuccess;

@property (nonatomic, assign)BOOL pulseSuccess;

@property (nonatomic, assign)BOOL totalSuccess;

- (BOOL)success;

+ (NSArray *)parseMonthList:(NSString *)timestamp dataList:(NSArray *)dataList;

+ (NSArray *)parseDaily:(NSArray *)dataList;

@end

NS_ASSUME_NONNULL_END
