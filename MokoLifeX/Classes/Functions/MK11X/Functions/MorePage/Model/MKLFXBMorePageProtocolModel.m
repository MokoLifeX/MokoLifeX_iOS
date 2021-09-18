//
//  MKLFXBMorePageProtocolModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBMorePageProtocolModel.h"

#import "MKLFXBMQTTInterface.h"
#import "MKLFXBMQTTManager.h"

@implementation MKLFXBUpdateDataModel

- (NSString *)updateResultNotificationName {
    return MKLFXBReceiveUpdateResultNotification;
}

- (void)updateFile:(NSInteger)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
          deviceID:(NSString *)deviceID
             topic:(NSString *)topic
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError * _Nonnull))failedBlock {
    [MKLFXBMQTTInterface lfxb_updateFile:fileType
                                    host:host
                                    port:port
                               catalogue:catalogue
                                deviceID:deviceID
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

@end


@implementation MKLFXBDeviceInfoDataModel

/// 接收到固件信息通知的名称
- (NSString *)firmwareInfoNotificationName {
    return MKLFXBReceiveFirmwareInfoNotification;
}

- (void)readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
                                            topic:(NSString *)topic
                                         sucBlock:(void (^)(void))sucBlock
                                      failedBlock:(void (^)(NSError *error))failedBlock {
    [MKLFXBMQTTInterface lfxb_readDeviceFirmwareInformationWithDeviceID:deviceID
                                                                  topic:topic
                                                               sucBlock:sucBlock
                                                            failedBlock:failedBlock];
}

@end


@implementation MKLFXBPowerOnStatusModel

/// 上电状态通知名称
- (NSString *)powerOnStatusNotificationName {
    return MKLFXBReceiveDevicePowerOnStatusNotification;
}

- (void)configDevicePowerOnStatus:(NSInteger)status
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    [MKLFXBMQTTInterface lfxb_configDevicePowerOnStatus:status
                                               deviceID:deviceID
                                                  topic:topic
                                               sucBlock:sucBlock
                                            failedBlock:failedBlock];
}

- (void)readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                      topic:(NSString *)topic
                                   sucBlock:(void (^)(void))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock {
    [MKLFXBMQTTInterface lfxb_readDevicePowerOnStatusWithDeviceID:deviceID
                                                            topic:topic
                                                         sucBlock:sucBlock
                                                      failedBlock:failedBlock];
}

@end
