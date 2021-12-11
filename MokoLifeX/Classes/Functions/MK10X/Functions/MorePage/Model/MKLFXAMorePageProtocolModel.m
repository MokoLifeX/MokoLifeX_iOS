//
//  MKLFXAMorePageProtocolModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAMorePageProtocolModel.h"

#import "MKLFXAMQTTInterface.h"
#import "MKLFXAMQTTManager.h"

@implementation MKLFXAUpdateDataModel

- (NSString *)updateResultNotificationName {
    return MKLFXAReceiveUpdateResultNotification;
}

- (void)updateFile:(NSInteger)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
          deviceID:(NSString *)deviceID
             topic:(NSString *)topic
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError * _Nonnull))failedBlock {
    [MKLFXAMQTTInterface lfxa_updateFile:fileType
                                    host:host
                                    port:port
                               catalogue:catalogue
                                deviceID:deviceID
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

@end


@implementation MKLFXADeviceInfoDataModel

/// 接收到固件信息通知的名称
- (NSString *)firmwareInfoNotificationName {
    return MKLFXAReceiveFirmwareInfoNotification;
}

- (void)readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
                                            topic:(NSString *)topic
                                         sucBlock:(void (^)(void))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock {
    [MKLFXAMQTTInterface lfxa_readDeviceFirmwareInformationWithDeviceID:deviceID
                                                                  topic:topic
                                                               sucBlock:sucBlock
                                                            failedBlock:failedBlock];
}

@end


@implementation MKLFXAPowerOnStatusModel

/// 上电状态通知名称
- (NSString *)powerOnStatusNotificationName {
    return MKLFXAReceiveDevicePowerOnStatusNotification;
}

- (void)configDevicePowerOnStatus:(NSInteger)status
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    [MKLFXAMQTTInterface lfxa_configDevicePowerOnStatus:status
                                               deviceID:deviceID
                                                  topic:topic
                                               sucBlock:sucBlock
                                            failedBlock:failedBlock];
}

- (void)readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                      topic:(NSString *)topic
                                   sucBlock:(void (^)(void))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock {
    [MKLFXAMQTTInterface lfxa_readDevicePowerOnStatusWithDeviceID:deviceID
                                                            topic:topic
                                                         sucBlock:sucBlock
                                                      failedBlock:failedBlock];
}

@end
