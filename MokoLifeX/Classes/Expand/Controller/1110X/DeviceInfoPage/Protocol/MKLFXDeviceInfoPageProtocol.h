//
//  MKLFXDeviceInfoPageProtocol.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXDeviceInfoPageProtocol <NSObject>

/// 接收到固件信息通知的名称
- (NSString *)firmwareInfoNotificationName;

/// 读取设备固件信息
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
                                            topic:(NSString *)topic
                                         sucBlock:(void (^)(void))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
