//
//  MKLFXAMQTTInterface.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_lfxa_updateFileType) {
    mk_lfxa_updateFirmware,
    mk_lfxa_updateCAFile,
    mk_lfxa_updateClientCertificate,
    mk_lfxa_updateClientPrivateKey,
};

typedef NS_ENUM(NSInteger, mk_lfxa_devicePowerOnStatus) {
    mk_lfxa_devicePowerOnStatusOff,
    mk_lfxa_devicePowerOnStatusOn,
    mk_lfxa_devicePowerOnStatusRevertLast,
};

@interface MKLFXAMQTTInterface : NSObject

/// 改变开关状态
/// @param isOn isOn
/// @param deviceID deviceID,1-32 Characters
/// @param topic topic 1-128 Characters
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxa_configDeviceSwitchState:(BOOL)isOn
                            deviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Plug for countdown. When the time is up, The socket will switch on/off according to the countdown settings
/// @param delay_hour Hour range:0~23
/// @param delay_minutes Minute range:0~59
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxa_setDeviceDelayHour:(NSInteger)delay_hour
                       delayMin:(NSInteger)delay_minutes
                       deviceID:(NSString *)deviceID
                          topic:(NSString *)topic
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Factory Reset
 
 @param deviceID deviceID
 @param topic topic
 @param sucBlock       Success callback
 @param failedBlock    Failed callback
 */
+ (void)lfxa_resetDeviceWithDeviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Read device information
 
 @param deviceID deviceID
 @param topic topic
 @param sucBlock      Success callback
 @param failedBlock   Failed callback
 */
+ (void)lfxa_readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
                                                 topic:(NSString *)topic
                                              sucBlock:(void (^)(void))sucBlock
                                           failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Plug OTA upgrade
 
 @param fileType file type
 @param host The IP address or domain name of the new firmware host.1-64 Characters.
 @param port Range 0~65535
 @param catalogue 1-100 Characters.
 @param topic update file topic
 @param deviceID deviceID
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)lfxa_updateFile:(mk_lfxa_updateFileType)fileType
                   host:(NSString *)host
                   port:(NSInteger)port
              catalogue:(NSString *)catalogue
               deviceID:(NSString *)deviceID
                  topic:(NSString *)topic
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

/**
 When setting equipment electrical switch state by default
 
 @param status status
 @param deviceID deviceID
 @param topic topic
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)lfxa_configDevicePowerOnStatus:(mk_lfxa_devicePowerOnStatus)status
                              deviceID:(NSString *)deviceID
                                 topic:(NSString *)topic
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Read equipment electrical switch state by default
 
 @param deviceID deviceID
 @param topic topic
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)lfxa_readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                           topic:(NSString *)topic
                                        sucBlock:(void (^)(void))sucBlock
                                     failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
