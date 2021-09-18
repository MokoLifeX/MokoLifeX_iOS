//
//  MKLFXCMQTTInterface.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/8.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTInterface.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXCMQTTManager.h"

@implementation MKLFXCMQTTInterface

+ (void)lfxc_readDeviceSwitchStateWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2026),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configDeviceSwitchState:(BOOL)isOn
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
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_setDeviceDelayHour:(NSInteger)delay_hour
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
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_resetDeviceWithDeviceID:(NSString *)deviceID
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
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
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
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_updateFile:(mk_lfxc_updateFileType)fileType
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
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configDevicePowerOnStatus:(mk_lfxc_devicePowerOnStatus)status
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
                                      @"default_status":@(status)
                                      }
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
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
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readLEDColorWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2008),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_setLEDColor:(mk_lfxc_ledColorType)colorType
           colorProtocol:(nullable id <mk_lfxc_ledColorConfigProtocol>)protocol
            productModel:(mk_lfxc_productModel)productModel
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
    if (![self checkLEDColorParams:colorType colorProtocol:protocol productModel:productModel]) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2010),
                              @"id":deviceID,
                              @"data":[self loadColorDataDic:colorType colorProtocol:protocol],
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readPowerReportIntervalWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2014),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configPowerReportInterval:(NSInteger)interval
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
    if (interval < 1 || interval > 600) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2015),
                              @"id":deviceID,
                              @"data":@{
                                  @"report_interval":@(interval),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readEnergyParamsWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2016),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configEnergyParams:(NSInteger)interval
                    powerChange:(NSInteger)powerChange
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
    if (interval < 1 || interval > 60 || powerChange < 1 || powerChange > 100) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2017),
                              @"id":deviceID,
                              @"data":@{
                                  @"time_interval":@(interval),
                                  @"power_change":@(powerChange),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readPulseConstantWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2020),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readEnergyDataOfTodayWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2019),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readHistoricalEnergyWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2018),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readTotalEnergyWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2021),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_resetAccumulatedEnergyWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2023),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configSwitchStatusReportInterval:(NSInteger)interval
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
    if (interval < 1 || interval > 600) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2100),
                              @"id":deviceID,
                              @"data":@{
                                  @"report_interval":@(interval),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readSwitchStatusReportIntervalWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2101),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configOverLoadParams:(BOOL)isOn
                   powerThreshold:(NSInteger)powerThreshold
                    timeThreshold:(NSInteger)timeThreshold
                     productModel:(mk_lfxc_productModel)productModel
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
    NSInteger maxValue = 4416;
    if (productModel == mk_lfxc_productModel_B) {
        maxValue = 2160;
    }else if (productModel == mk_lfxc_productModel_G) {
        maxValue = 3588;
    }
    if (isOn && (powerThreshold < 10 || powerThreshold > maxValue || timeThreshold < 1 || timeThreshold > 30)) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2102),
                              @"id":deviceID,
                              @"data":@{
                                      @"protection_enable":(isOn ? @(1) : @(0)),
                                      @"protection_value":@(powerThreshold),
                                      @"judge_time":@(timeThreshold)
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readOverLoadParamsWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2103),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_clearOverLoadStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2104),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readOverLoadStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2105),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configOverVoltageParams:(BOOL)isOn
                    voltageThreshold:(NSInteger)voltageThreshold
                       timeThreshold:(NSInteger)timeThreshold
                        productModel:(mk_lfxc_productModel)productModel
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
    NSInteger maxValue = 264;
    NSInteger minValue = 200;
    if (productModel == mk_lfxc_productModel_B) {
        maxValue = 138;
        minValue = 100;
    }else if (productModel == mk_lfxc_productModel_G) {
        maxValue = 264;
        minValue = 200;
    }
    if (isOn && (voltageThreshold < minValue || voltageThreshold > maxValue || timeThreshold < 1 || timeThreshold > 30)) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2106),
                              @"id":deviceID,
                              @"data":@{
                                      @"protection_enable":(isOn ? @(1) : @(0)),
                                      @"protection_value":@(voltageThreshold),
                                      @"judge_time":@(timeThreshold)
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readOverVoltageParamsWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2107),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_clearOverVoltageStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2108),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readOverVoltageStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2109),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configOverCurrentParams:(BOOL)isOn
                    currentThreshold:(double)currentThreshold
                       timeThreshold:(NSInteger)timeThreshold
                        productModel:(mk_lfxc_productModel)productModel
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
    double maxValue = 19.2;
    double minValue = 0.1;
    if (productModel == mk_lfxc_productModel_B) {
        maxValue = 18;
        minValue = 0.1;
    }else if (productModel == mk_lfxc_productModel_G) {
        maxValue = 15.6;
        minValue = 0.1;
    }
    if (isOn && (currentThreshold < minValue || currentThreshold > maxValue || timeThreshold < 1 || timeThreshold > 30)) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDecimalNumberHandler *roundBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                                                   scale:1
                                                                                        raiseOnExactness:NO
                                                                                         raiseOnOverflow:NO
                                                                                        raiseOnUnderflow:NO
                                                                                     raiseOnDivideByZero:NO];
    NSDecimalNumber *value = [[NSDecimalNumber alloc] initWithDouble:currentThreshold];
    NSDecimalNumber *resultValue = [value decimalNumberByRoundingAccordingToBehavior:roundBehavior];
    NSDictionary *dataDic = @{
                              @"msg_id":@(2110),
                              @"id":deviceID,
                              @"data":@{
                                      @"protection_enable":(isOn ? @(1) : @(0)),
                                      @"protection_value":resultValue,
                                      @"judge_time":@(timeThreshold)
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readOverCurrentParamsWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2111),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_clearOverCurrentStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2112),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readOverCurrentStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2113),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configNTPServer:(BOOL)isOn
                      domain:(NSString *)domain
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
    if (![domain isKindOfClass:NSString.class] || domain.length > 64) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2114),
                              @"id":deviceID,
                              @"data":@{
                                      @"ntp_enable":(isOn ? @(1) : @(0)),
                                      @"domain":SafeStr(domain),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readNTPServerParamsWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2115),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_ConfigLoadChangeStatus:(BOOL)removeIsOn
                         accessIsOn:(BOOL)accessIsOn
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
                              @"msg_id":@(2116),
                              @"id":deviceID,
                              @"data":@{
                                      @"remove_notice":(removeIsOn ? @(1) : @(0)),
                                      @"access_notice":(accessIsOn ? @(1) : @(0))
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readLoadChangeStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2117),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configRCLedStatus:(BOOL)powerIsOn
                   networkIsOn:(BOOL)networkIsOn
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
                              @"msg_id":@(2118),
                              @"id":deviceID,
                              @"data":@{
                                      @"power_led":(powerIsOn ? @(1) : @(0)),
                                      @"network_led":(networkIsOn ? @(1) : @(0))
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readRCLedStatusWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2119),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configConnectionTimeout:(NSInteger)timeout
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
    if (timeout < 0 || timeout > 1440) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2120),
                              @"id":deviceID,
                              @"data":@{
                                  @"timeout":@(timeout),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readConnectionTimeoutWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2121),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readDeviceTimeWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2122),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_readDeviceMQTTParamsWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2123),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configDeviceTimeZone:(NSInteger)timeZone
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
    if (timeZone < -24 || timeZone > 24) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2124),
                              @"id":deviceID,
                              @"data":@{
                                      @"timestamp":@((long long)[[NSDate date] timeIntervalSince1970]),
                                      @"time_zone":@(timeZone),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
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

+ (BOOL)checkLEDColorParams:(mk_lfxc_ledColorType)colorType
              colorProtocol:(nullable id <mk_lfxc_ledColorConfigProtocol>)protocol
               productModel:(mk_lfxc_productModel)productModel{
    if (colorType == mk_lfxc_ledColorTransitionSmoothly || colorType == mk_lfxc_ledColorTransitionDirectly) {
        if (!protocol || ![protocol conformsToProtocol:@protocol(mk_lfxc_ledColorConfigProtocol)]) {
            return NO;
        }
        NSInteger maxValue = 4416;
        if (productModel == mk_lfxc_productModel_B) {
            maxValue = 2160;
        }else if (productModel == mk_lfxc_productModel_G) {
            maxValue = 3588;
        }
        if (protocol.b_color < 1 || protocol.b_color > (maxValue - 5)) {
            return NO;
        }
        if (protocol.g_color <= protocol.b_color || protocol.g_color > (maxValue - 4)) {
            return NO;
        }
        if (protocol.y_color <= protocol.g_color || protocol.y_color > (maxValue - 3)) {
            return NO;
        }
        if (protocol.o_color <= protocol.y_color || protocol.o_color > (maxValue - 2)) {
            return NO;
        }
        if (protocol.r_color <= protocol.o_color || protocol.r_color > (maxValue - 1)) {
            return NO;
        }
        if (protocol.p_color <= protocol.r_color || protocol.p_color > maxValue) {
            return NO;
        }
    }
    return YES;
}

+ (NSDictionary *)loadColorDataDic:(mk_lfxc_ledColorType)colorType
                     colorProtocol:(nullable id <mk_lfxc_ledColorConfigProtocol>)protocol {
    if (colorType == mk_lfxc_ledColorTransitionSmoothly || colorType == mk_lfxc_ledColorTransitionDirectly) {
        return @{
            @"led_state":@(colorType),
            @"blue":@(protocol.b_color),
            @"green":@(protocol.g_color),
            @"yellow":@(protocol.y_color),
            @"orange":@(protocol.o_color),
            @"red":@(protocol.r_color),
            @"purple":@(protocol.p_color),
        };
    }
    return @{
        @"led_state":@(colorType),
    };
}

@end
