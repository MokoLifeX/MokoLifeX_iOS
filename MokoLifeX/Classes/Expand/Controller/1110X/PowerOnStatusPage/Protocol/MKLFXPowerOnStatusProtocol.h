//
//  MKLFXPowerOnStatusProtocol.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXPowerOnStatusProtocol <NSObject>

/// 上电状态通知名称
- (NSString *)powerOnStatusNotificationName;


/// 设置设备上电状态
/// @param status 0:Switched off,   1:Switched on,    2:Revert to the last status
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)configDevicePowerOnStatus:(NSInteger)status
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备上电状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                      topic:(NSString *)topic
                                   sucBlock:(void (^)(void))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
