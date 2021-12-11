//
//  MKLFXBMQTTInterface.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/27.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_lfxb_updateFileType) {
    mk_lfxb_updateFirmware,
    mk_lfxb_updateCAFile,
    mk_lfxb_updateClientCertificate,
    mk_lfxb_updateClientPrivateKey,
};

typedef NS_ENUM(NSInteger, mk_lfxb_devicePowerOnStatus) {
    mk_lfxb_devicePowerOnStatusOff,
    mk_lfxb_devicePowerOnStatusOn,
    mk_lfxb_devicePowerOnStatusRevertLast,
};

typedef NS_ENUM(NSInteger, mk_lfxb_ledColorType) {
    mk_lfxb_ledColorTransitionDirectly,
    mk_lfxb_ledColorTransitionSmoothly,
    mk_lfxb_ledColorWhite,
    mk_lfxb_ledColorRed,
    mk_lfxb_ledColorGreen,
    mk_lfxb_ledColorBlue,
    mk_lfxb_ledColorOrange,
    mk_lfxb_ledColorCyan,
    mk_lfxb_ledColorPurple,
    mk_lfxb_ledColorDisable,
};

@protocol mk_lfxb_ledColorConfigProtocol <NSObject>

/// Blue..
/// 1 <=  b_color <= 3790.
@property (nonatomic, assign)NSInteger b_color;

/// Green
/// b_color < g_color <= 3791.
@property (nonatomic, assign)NSInteger g_color;

/// Yellow
/// g_color < y_color <= 3792.
@property (nonatomic, assign)NSInteger y_color;

/// Orange
/// y_color < o_color <= 3793.
@property (nonatomic, assign)NSInteger o_color;

/// Red
/// o_color < r_color <= 3794.
@property (nonatomic, assign)NSInteger r_color;

/// Purple
/// r_color < p_color <=  3795.
@property (nonatomic, assign)NSInteger p_color;

@end

@interface MKLFXBMQTTInterface : NSObject

/// Switch State.
/// @param isOn isOn
/// @param deviceID deviceID,1-32 Characters
/// @param topic topic 1-128 Characters
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxb_configDeviceSwitchState:(BOOL)isOn
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
+ (void)lfxb_setDeviceDelayHour:(NSInteger)delay_hour
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
+ (void)lfxb_resetDeviceWithDeviceID:(NSString *)deviceID
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
+ (void)lfxb_readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
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
+ (void)lfxb_updateFile:(mk_lfxb_updateFileType)fileType
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
+ (void)lfxb_configDevicePowerOnStatus:(mk_lfxb_devicePowerOnStatus)status
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
+ (void)lfxb_readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                           topic:(NSString *)topic
                                        sucBlock:(void (^)(void))sucBlock
                                     failedBlock:(void (^)(NSError *error))failedBlock;

/// Read device overload status.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readOverloadValueWithDeviceID:(NSString *)deviceID
                                     topic:(NSString *)topic
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// Set device overload status.
/// @param value overload status.10-3795W
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_setOverloadValue:(NSInteger)value
                     deviceID:(NSString *)deviceID
                        topic:(NSString *)topic
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Reporting interval of reading power information.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readPowerReportPeriodWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the interval for reporting power information.
/// @param period 1s~600s
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_setPowerReportPeriod:(NSInteger)period
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// Reporting interval of reading energy information.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readEnergyReportPeriodWithDeviceID:(NSString *)deviceID
                                          topic:(NSString *)topic
                                       sucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the interval for reporting energy information.
/// @param period 1mins~60mins
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_setEnergyReportPeriod:(NSInteger)period
                          deviceID:(NSString *)deviceID
                             topic:(NSString *)topic
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

/// Reading cumulative energy storage parameters.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readEnergyStorageParametersWithDeviceID:(NSString *)deviceID
                                               topic:(NSString *)topic
                                            sucBlock:(void (^)(void))sucBlock
                                         failedBlock:(void (^)(NSError *error))failedBlock;

/// Set cumulative energy storage parameters
/// @param interval Storage time interval, the interval is 1min-60min
/// @param energyValue Energy change value, range is 1%-100%
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_setEnergyStorageParameters:(NSInteger)interval
                            energyValue:(NSInteger)energyValue
                               deviceID:(NSString *)deviceID
                                  topic:(NSString *)topic
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the indicator status and power indicator range when the socket switch is turned on.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readLEDColorWithDeviceID:(NSString *)deviceID
                                topic:(NSString *)topic
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the indicator status and power indicator range when the socket switch is turned on.
/// @param colorType colorType
/// @param protocol mk_lfxb_ledColorConfigProtocol,Note: When colorType is one of mk_lfxb_ledColorTransitionSmoothly and mk_lfxb_ledColorTransitionDirectly, it cannot be empty, other types are not checked.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_setLEDColor:(mk_lfxb_ledColorType)colorType
           colorProtocol:(nullable id <mk_lfxb_ledColorConfigProtocol>)protocol
                deviceID:(NSString *)deviceID
                   topic:(NSString *)topic
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// Read pulse constant.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readPulseConstantWithDeviceID:(NSString *)deviceID
                                     topic:(NSString *)topic
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// Read hourly data for the day.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readEnergyDataOfTodayWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// Read historical accumulated energy, up to 30 days of data
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readHistoricalEnergyWithDeviceID:(NSString *)deviceID
                                        topic:(NSString *)topic
                                     sucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the total accumulated energy.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_readTotalEnergyWithDeviceID:(NSString *)deviceID
                                   topic:(NSString *)topic
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// Reset energy consumption.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_resetAccumulatedEnergyWithDeviceID:(NSString *)deviceID
                                          topic:(NSString *)topic
                                       sucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Synchronize device time.
/// @param date date,formatter:yyyy-MM-dd HH:mm:ss
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxb_setDeviceDate:(NSDate *)date
                  deviceID:(NSString *)deviceID
                     topic:(NSString *)topic
                  sucBlock:(void (^)(void))sucBlock
               failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
