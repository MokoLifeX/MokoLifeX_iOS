//
//  MKEnergyDataModel.h
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MKEnergyDataModelSucBlock)(NSArray *dailyList, NSArray *monthlyList, NSString *pulseConstant, NSString *totalEnergy);
typedef void(^MKEnergyDataModelFailedBlock) (NSError *error);

@interface MKEnergyDataModel : NSObject

- (void)startReadEnergyDatasWithScuBlock:(MKEnergyDataModelSucBlock)sucBlock
                             failedBlock:(MKEnergyDataModelFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
