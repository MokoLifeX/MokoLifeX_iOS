//
//  MKLFXCEnergyDataModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCEnergyDataModel.h"

@implementation MKLFXCEnergyDataModel

- (BOOL)success {
    if (!self.dailySuccess || !self.monthSuccess || !self.pulseSuccess || !self.totalSuccess) {
        return NO;
    }
    return YES;
}

+ (NSArray *)parseMonthList:(NSString *)timestamp dataList:(NSArray *)dataList {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *recordDate = [dateFormat dateFromString:timestamp];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *dic in dataList) {
        NSInteger index = [dic[@"offset"] integerValue];
        NSDate *tempDate = [[NSDate alloc] initWithTimeInterval:(24 * 60 * 60 * index) sinceDate:recordDate];
        NSString *tempTime = [dateFormat stringFromDate:tempDate];
        NSDictionary *tempDic = @{
            @"date":tempTime,
            @"rotationsNumber":[NSString stringWithFormat:@"%ld",(long)[dic[@"value"] integerValue]],
            @"index":[NSString stringWithFormat:@"%ld",(long)index],
        };
        [list addObject:tempDic];
    }
    return list;
}

+ (NSArray *)parseDaily:(NSArray *)dataList {
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *tempDic in dataList) {
        NSDictionary *dic = @{
            @"index":[NSString stringWithFormat:@"%ld",(long)[tempDic[@"offset"] integerValue]],
            @"rotationsNumber":[NSString stringWithFormat:@"%ld",(long)[tempDic[@"value"] integerValue]],
        };
        [list addObject:dic];
    }
    return list;
}

@end
