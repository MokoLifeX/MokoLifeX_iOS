//
//  MKMQTTServerInterface+MK115Add.m
//  MokoLifeX
//
//  Created by aa on 2020/6/17.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKMQTTServerInterface+MK115Add.h"

#import "MKMQTTServerErrorBlockAdopter.h"

@implementation MKMQTTServerInterface (MK115Add)

+ (void)readOverloadValueWithTopic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2012),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)setOverloadValue:(NSInteger)value
                   topic:(NSString *)topic
                  mqttID:(NSString *)mqttID
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (value < 10 || value > 2530) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2013),
                              @"id":mqttID,
                              @"data":@{
                                      @"overload_value":@(value),
                                      }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readPowerReportPeriodWithTopic:(NSString *)topic
                                mqttID:(NSString *)mqttID
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2014),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)setPowerReportPeriod:(NSInteger)period
                       topic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    if (period < 1 || period > 600) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2015),
                              @"id":mqttID,
                              @"data":@{
                                      @"report_interval":@(period),
                                      }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readEnergyReportPeriodWithTopic:(NSString *)topic
                                 mqttID:(NSString *)mqttID
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2025),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)setEnergyReportPeriod:(NSInteger)period
                        topic:(NSString *)topic
                       mqttID:(NSString *)mqttID
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (period < 1 || period > 60) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2024),
                              @"id":mqttID,
                              @"data":@{
                                      @"report_interval":@(period),
                                      }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readEnergyStorageParametersWithTopic:(NSString *)topic
                                      mqttID:(NSString *)mqttID
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2016),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)setEnergyStorageParameters:(NSInteger)interval
                       energyValue:(NSInteger)energyValue
                             topic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    if (interval < 1 || interval > 60 || energyValue < 1 || energyValue > 100) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2017),
                              @"id":mqttID,
                              @"data":@{
                                      @"time_interval":@(interval),
                                      @"power_change":@(energyValue),
                                      }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readLEDColorWithTopic:(NSString *)topic
                       mqttID:(NSString *)mqttID
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2008),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)setLEDColor:(mk_ledColorType)colorType
      colorProtocol:(nullable id <mk_ledColorConfigProtocol>)protocol
              topic:(NSString *)topic
             mqttID:(NSString *)mqttID
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock {
    if (![self checkLEDColorParams:colorType colorProtocol:protocol]) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2010),
                              @"id":mqttID,
                              @"data":[self loadColorDataDic:colorType colorProtocol:protocol],
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readPulseConstantWithTopic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2020),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readEnergyDataOfTodayWithTopic:(NSString *)topic
                                mqttID:(NSString *)mqttID
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2019),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readHistoricalEnergyWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2018),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readTotalEnergyWithTopic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2021),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)resetAccumulatedEnergyWithTopic:(NSString *)topic
                                 mqttID:(NSString *)mqttID
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2023),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)setDeviceDate:(NSDate *)date
                topic:(NSString *)topic
               mqttID:(NSString *)mqttID
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSArray *dateList = [dateString componentsSeparatedByString:@" "];
    NSDictionary *dataDic = @{
                              @"msg_id":@(2022),
                              @"id":mqttID,
                              @"data":@{
                                      @"timestamp": [NSString stringWithFormat:@"%@&%@",dateList[0],dateList[1]],
                                    }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

#pragma mark - Private method
+ (BOOL)checkLEDColorParams:(mk_ledColorType)colorType
              colorProtocol:(nullable id <mk_ledColorConfigProtocol>)protocol {
    if (colorType == mk_ledColorTransitionSmoothly || colorType == mk_ledColorTransitionDirectly) {
        if (!protocol || ![protocol conformsToProtocol:@protocol(mk_ledColorConfigProtocol)]) {
            return NO;
        }
        if (protocol.b_color < 1 || protocol.b_color >= 2525) {
            return NO;
        }
        if (protocol.g_color <= protocol.b_color || protocol.g_color >= 2526) {
            return NO;
        }
        if (protocol.y_color <= protocol.g_color || protocol.y_color >= 2527) {
            return NO;
        }
        if (protocol.o_color <= protocol.y_color || protocol.o_color >= 2528) {
            return NO;
        }
        if (protocol.r_color <= protocol.o_color || protocol.r_color >= 2529) {
            return NO;
        }
        if (protocol.p_color <= protocol.r_color || protocol.p_color >= 2530) {
            return NO;
        }
    }
    return YES;
}

+ (NSDictionary *)loadColorDataDic:(mk_ledColorType)colorType
                     colorProtocol:(nullable id <mk_ledColorConfigProtocol>)protocol {
    if (colorType == mk_ledColorTransitionSmoothly || colorType == mk_ledColorTransitionDirectly) {
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
