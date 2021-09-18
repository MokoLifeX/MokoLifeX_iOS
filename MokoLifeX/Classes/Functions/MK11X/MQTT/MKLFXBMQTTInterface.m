//
//  MKLFXBMQTTInterface.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/27.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBMQTTInterface.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXBMQTTManager.h"

@implementation MKLFXBMQTTInterface

+ (void)lfxb_configDeviceSwitchState:(BOOL)isOn
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setDeviceDelayHour:(NSInteger)delay_hour
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_resetDeviceWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_updateFile:(mk_lfxb_updateFileType)fileType
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_configDevicePowerOnStatus:(mk_lfxb_devicePowerOnStatus)status
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readOverloadValueWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2012),
                              @"id":deviceID,
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setOverloadValue:(NSInteger)value
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
    if (value < 10 || value > 3795) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2013),
                              @"id":deviceID,
                              @"data":@{
                                      @"overload_value":@(value),
                                      }
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readPowerReportPeriodWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setPowerReportPeriod:(NSInteger)period
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
    if (period < 1 || period > 600) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2015),
                              @"id":deviceID,
                              @"data":@{
                                      @"report_interval":@(period),
                                      }
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readEnergyReportPeriodWithDeviceID:(NSString *)deviceID
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
                              @"msg_id":@(2025),
                              @"id":deviceID,
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setEnergyReportPeriod:(NSInteger)period
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
    if (period < 1 || period > 60) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2024),
                              @"id":deviceID,
                              @"data":@{
                                      @"report_interval":@(period),
                                      }
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readEnergyStorageParametersWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setEnergyStorageParameters:(NSInteger)interval
                            energyValue:(NSInteger)energyValue
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
    if (interval < 1 || interval > 60 || energyValue < 1 || energyValue > 100) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2017),
                              @"id":deviceID,
                              @"data":@{
                                      @"time_interval":@(interval),
                                      @"power_change":@(energyValue),
                                      }
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readLEDColorWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setLEDColor:(mk_lfxb_ledColorType)colorType
           colorProtocol:(nullable id <mk_lfxb_ledColorConfigProtocol>)protocol
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
    if (![self checkLEDColorParams:colorType colorProtocol:protocol]) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2010),
                              @"id":deviceID,
                              @"data":[self loadColorDataDic:colorType colorProtocol:protocol],
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readPulseConstantWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readEnergyDataOfTodayWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readHistoricalEnergyWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_readTotalEnergyWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_resetAccumulatedEnergyWithDeviceID:(NSString *)deviceID
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
    [[MKLFXBMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxb_setDeviceDate:(NSDate *)date
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSArray *dateList = [dateString componentsSeparatedByString:@" "];
    NSDictionary *dataDic = @{
                              @"msg_id":@(2022),
                              @"id":deviceID,
                              @"data":@{
                                      @"timestamp": [NSString stringWithFormat:@"%@&%@",dateList[0],dateList[1]],
                                    }
                              };
    [[MKLFXBMQTTManager shared] sendData:dataDic
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

+ (BOOL)checkLEDColorParams:(mk_lfxb_ledColorType)colorType
              colorProtocol:(nullable id <mk_lfxb_ledColorConfigProtocol>)protocol {
    if (colorType == mk_lfxb_ledColorTransitionSmoothly || colorType == mk_lfxb_ledColorTransitionDirectly) {
        if (!protocol || ![protocol conformsToProtocol:@protocol(mk_lfxb_ledColorConfigProtocol)]) {
            return NO;
        }
        if (protocol.b_color < 1 || protocol.b_color > 3790) {
            return NO;
        }
        if (protocol.g_color <= protocol.b_color || protocol.g_color > 3791) {
            return NO;
        }
        if (protocol.y_color <= protocol.g_color || protocol.y_color > 3792) {
            return NO;
        }
        if (protocol.o_color <= protocol.y_color || protocol.o_color > 3793) {
            return NO;
        }
        if (protocol.r_color <= protocol.o_color || protocol.r_color > 3794) {
            return NO;
        }
        if (protocol.p_color <= protocol.r_color || protocol.p_color > 3795) {
            return NO;
        }
    }
    return YES;
}

+ (NSDictionary *)loadColorDataDic:(mk_lfxb_ledColorType)colorType
                     colorProtocol:(nullable id <mk_lfxb_ledColorConfigProtocol>)protocol {
    if (colorType == mk_lfxb_ledColorTransitionSmoothly || colorType == mk_lfxb_ledColorTransitionDirectly) {
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
