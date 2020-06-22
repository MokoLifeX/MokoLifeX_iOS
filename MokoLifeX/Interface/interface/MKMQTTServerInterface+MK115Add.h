//
//  MKMQTTServerInterface+MK115Add.h
//  MokoLifeX
//
//  Created by aa on 2020/6/17.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_ledColorType) {
    mk_ledColorTransitionSmoothly,
    mk_ledColorTransitionDirectly,
    mk_ledColorWhite,
    mk_ledColorRed,
    mk_ledColorGreen,
    mk_ledColorBlue,
    mk_ledColorOrange,
    mk_ledColorCyan,
    mk_ledColorPurple,
    mk_ledColorDisable,
};

@protocol mk_ledColorConfigProtocol <NSObject>

/// Blue..
/// 0 <  b_color < 2525.
@property (nonatomic, assign)NSInteger b_color;

/// Green
/// b_color < g_color < 2526.
@property (nonatomic, assign)NSInteger g_color;

/// Yellow
/// g_color < y_color < 2527.
@property (nonatomic, assign)NSInteger y_color;

/// Orange
/// y_color < o_color < 2528.
@property (nonatomic, assign)NSInteger o_color;

/// Red
/// o_color < r_color < 2529.
@property (nonatomic, assign)NSInteger r_color;

/// Purple
/// r_color < p_color <  2530.
@property (nonatomic, assign)NSInteger p_color;

@end

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

/// Read the indicator status and power indicator range when the socket switch is turned on.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readLEDColorWithTopic:(NSString *)topic
                       mqttID:(NSString *)mqttID
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the indicator status and power indicator range when the socket switch is turned on.
/// @param colorType colorType
/// @param protocol mk_ledColorConfigProtocol,Note: When colorType is one of mk_ledColorTransitionSmoothly and mk_ledColorTransitionDirectly, it cannot be empty, other types are not checked.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)setLEDColor:(mk_ledColorType)colorType
      colorProtocol:(nullable id <mk_ledColorConfigProtocol>)protocol
              topic:(NSString *)topic
             mqttID:(NSString *)mqttID
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock;

/// Read pulse constant.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readPulseConstantWithTopic:(NSString *)topic
                            mqttID:(NSString *)mqttID
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

/// Read hourly data for the day.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readEnergyDataOfTodayWithTopic:(NSString *)topic
                                mqttID:(NSString *)mqttID
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// Read historical accumulated energy, up to 30 days of data
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readHistoricalEnergyWithTopic:(NSString *)topic
                               mqttID:(NSString *)mqttID
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the total accumulated energy.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)readTotalEnergyWithTopic:(NSString *)topic
                          mqttID:(NSString *)mqttID
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// Reset energy consumption.
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)resetAccumulatedEnergyWithTopic:(NSString *)topic
                                 mqttID:(NSString *)mqttID
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// Synchronize device time.
/// @param date date,formatter:yyyy-MM-dd HH:mm:ss
/// @param topic topic
/// @param mqttID mqttID
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)setDeviceDate:(NSDate *)date
                topic:(NSString *)topic
               mqttID:(NSString *)mqttID
             sucBlock:(void (^)(void))sucBlock
          failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
