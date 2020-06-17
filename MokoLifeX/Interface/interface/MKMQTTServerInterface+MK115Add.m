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

@end
