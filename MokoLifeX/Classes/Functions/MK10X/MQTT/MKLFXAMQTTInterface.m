//
//  MKLFXAMQTTInterface.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAMQTTInterface.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXAMQTTManager.h"

@implementation MKLFXAMQTTInterface

+ (void)lfxa_configDeviceSwitchState:(BOOL)isOn
                            deviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2001),
                              @"id":deviceID,
                              @"data":@{
                                        @"switch_state" : (isOn ? @"on" : @"off"),
                                      }
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxa_setDeviceDelayHour:(NSInteger)delay_hour
                       delayMin:(NSInteger)delay_minutes
                       deviceID:(NSString *)deviceID
                          topic:(NSString *)topic
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    if (delay_hour < 0 || delay_hour > 23 || delay_minutes < 0 || delay_minutes > 59) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2002),
                              @"id":deviceID,
                              @"data":@{
                                      @"delay_hour":@(delay_hour),
                                      @"delay_minute":@(delay_minutes),
                                      }
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxa_resetDeviceWithDeviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2003),
                              @"id":deviceID,
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxa_readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
                                                 topic:(NSString *)topic
                                              sucBlock:(void (^)(void))sucBlock
                                           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2005),
                              @"id":deviceID,
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxa_updateFile:(mk_lfxa_updateFileType)fileType
                   host:(NSString *)host
                   port:(NSInteger)port
              catalogue:(NSString *)catalogue
               deviceID:(NSString *)deviceID
                  topic:(NSString *)topic
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    if (port < 0 || port > 65535 || !catalogue || !host) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2004),
                              @"id":deviceID,
                              @"data":@{
                                      @"file_type":@(fileType),
                                      @"domain_name":host,
                                      @"port":@(port),
                                      @"file_way":catalogue,
                                      }
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxa_configDevicePowerOnStatus:(mk_lfxa_devicePowerOnStatus)status
                              deviceID:(NSString *)deviceID
                                 topic:(NSString *)topic
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2006),
                              @"id":deviceID,
                              @"data":@{
                                      @"switch_state":@(status)
                                      }
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxa_readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                           topic:(NSString *)topic
                                        sucBlock:(void (^)(void))sucBlock
                                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2007),
                              @"id":deviceID,
                              };
    [[MKLFXAMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

#pragma mark - private method
+ (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.LFXMQTTInterface"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    moko_dispatch_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

@end
