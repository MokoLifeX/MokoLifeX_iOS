//
//  MKLFXMQTTInterface.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/28.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXMQTTInterface : NSObject

/// 改变开关状态
/// @param isOn isOn
/// @param deviceID deviceID,1-32 Characters
/// @param topic topic 1-128 Characters
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfx_configDeviceSwitchState:(BOOL)isOn
                           deviceID:(NSString *)deviceID
                              topic:(NSString *)topic
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
