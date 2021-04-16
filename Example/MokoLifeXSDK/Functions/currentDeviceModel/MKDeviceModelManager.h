//
//  MKDeviceModelManager.h
//  MokoLifeX
//
//  Created by aa on 2020/6/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKDeviceModelManagerDelegate <NSObject>

- (void)currentDeviceModelStateChanged:(MKSmartPlugState)plugState;

@end

@interface MKDeviceModelManager : NSObject

@property (nonatomic, strong ,readonly)MKDeviceModel *deviceModel;

@property (nonatomic, weak)id <MKDeviceModelManagerDelegate>delegate;

+ (MKDeviceModelManager *)shared;

- (void)managementDeviceModel:(MKDeviceModel *)deviceModel;
- (void)clearManagementModel;
- (NSString *)subTopic;

@end

NS_ASSUME_NONNULL_END
