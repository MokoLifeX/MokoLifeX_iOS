//
//  MKMQTTServerInterface+MK115Add.h
//  MokoLifeX
//
//  Created by aa on 2020/6/17.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKMQTTServerInterface (MK115Add)

#pragma mark - Read

/// Read device overload status.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readOverloadValueWithTopic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

/// Set device overload status.
/// @param value overload status.10-2530W
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)setOverloadValue:(NSInteger)value
                   topic:(NSString *)topic
                  mqttID:(NSString *)mqttID
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Reporting interval of reading power information.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readPowerReportPeriodWithTopic:(NSString *)topic
                                mqttID:(NSString *)mqttID
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the interval for reporting power information.
/// @param period 1Mins~600Mins
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)setPowerReportPeriod:(NSInteger)period
                       topic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// Reporting interval of reading energy information.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readEnergyReportPeriodWithTopic:(NSString *)topic
                                 mqttID:(NSString *)mqttID
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the interval for reporting energy information.
/// @param period 1mins~60mins
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)setEnergyReportPeriod:(NSInteger)period
                        topic:(NSString *)topic
                       mqttID:(NSString *)mqttID
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Reading cumulative energy storage parameters.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readEnergyStorageParametersWithTopic:(NSString *)topic
                                      mqttID:(NSString *)mqttID
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

/// Set cumulative energy storage parameters
/// @param interval Storage time interval, the interval is 1min-60min
/// @param energyValue Energy change value, range is 1%-100%
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)setEnergyStorageParameters:(NSInteger)interval
                       energyValue:(NSInteger)energyValue
                             topic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
