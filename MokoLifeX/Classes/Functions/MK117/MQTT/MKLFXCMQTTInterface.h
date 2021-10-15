//
//  MKLFXCMQTTInterface.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/8.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_lfxc_updateFileType) {
    mk_lfxc_updateFirmware,
    mk_lfxc_updateCAFile,
    mk_lfxc_updateClientCertificate,
    mk_lfxc_updateClientPrivateKey,
};

typedef NS_ENUM(NSInteger, mk_lfxc_devicePowerOnStatus) {
    mk_lfxc_devicePowerOnStatusOff,
    mk_lfxc_devicePowerOnStatusOn,
    mk_lfxc_devicePowerOnStatusRevertLast,
};

typedef NS_ENUM(NSInteger, mk_lfxc_ledColorType) {
    mk_lfxc_ledColorTransitionDirectly,
    mk_lfxc_ledColorTransitionSmoothly,
    mk_lfxc_ledColorWhite,
    mk_lfxc_ledColorRed,
    mk_lfxc_ledColorGreen,
    mk_lfxc_ledColorBlue,
    mk_lfxc_ledColorOrange,
    mk_lfxc_ledColorCyan,
    mk_lfxc_ledColorPurple,
};

typedef NS_ENUM(NSInteger, mk_lfxc_productModel) {
    mk_lfxc_productModel_FE,                 //欧法规
    mk_lfxc_productModel_B,                  //美规
    mk_lfxc_productModel_G,                 //英规
};

@protocol mk_lfxc_ledColorConfigProtocol <NSObject>

/*
 Blue.
 European and French specifications:1 <=  b_color <= 4411.
 American specifications:1 <=  b_color <= 2155.
 British specifications:1 <=  b_color <= 3584.
 */
@property (nonatomic, assign)NSInteger b_color;

/*
 Green.
 European and French specifications:b_color < g_color <= 4412.
 American specifications:b_color < g_color <= 2156.
 British specifications:b_color < g_color <= 3584.
 */
@property (nonatomic, assign)NSInteger g_color;

/*
 Yellow.
 European and French specifications:g_color < y_color <= 4413.
 American specifications:g_color < y_color <= 2157.
 British specifications:g_color < y_color <= 3585.
 */
@property (nonatomic, assign)NSInteger y_color;

/*
 Orange.
 European and French specifications:y_color < o_color <= 4414.
 American specifications:y_color < o_color <= 2158.
 British specifications:y_color < o_color <= 3586.
 */
@property (nonatomic, assign)NSInteger o_color;

/*
 Red.
 European and French specifications:o_color < r_color <= 4415.
 American specifications:o_color < r_color <= 2159.
 British specifications:o_color < r_color <= 3587.
 */
@property (nonatomic, assign)NSInteger r_color;

/*
 Purple.
 European and French specifications:r_color < p_color <=  4416.
 American specifications:r_color < p_color <=  2160.
 British specifications:r_color < p_color <=  3588.
 */
@property (nonatomic, assign)NSInteger p_color;

@end

@interface MKLFXCMQTTInterface : NSObject

/// 读取开关状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readDeviceSwitchStateWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 改变开关状态
/// @param isOn isOn
/// @param deviceID deviceID,1-32 Characters
/// @param topic topic 1-128 Characters
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configDeviceSwitchState:(BOOL)isOn
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
+ (void)lfxc_setDeviceDelayHour:(NSInteger)delay_hour
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
+ (void)lfxc_resetDeviceWithDeviceID:(NSString *)deviceID
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
+ (void)lfxc_readDeviceFirmwareInformationWithDeviceID:(NSString *)deviceID
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
+ (void)lfxc_updateFile:(mk_lfxc_updateFileType)fileType
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
+ (void)lfxc_configDevicePowerOnStatus:(mk_lfxc_devicePowerOnStatus)status
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
+ (void)lfxc_readDevicePowerOnStatusWithDeviceID:(NSString *)deviceID
                                           topic:(NSString *)topic
                                        sucBlock:(void (^)(void))sucBlock
                                     failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the indicator status and power indicator range when the socket switch is turned on.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_readLEDColorWithDeviceID:(NSString *)deviceID
                                topic:(NSString *)topic
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// Set the indicator status and power indicator range when the socket switch is turned on.
/// @param colorType colorType
/// @param protocol mk_lfxc_ledColorConfigProtocol,Note: When colorType is one of mk_lfxc_ledColorTransitionSmoothly and mk_lfxc_ledColorTransitionDirectly, it cannot be empty, other types are not checked.
/// @param productModel Product model of the device.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_setLEDColor:(mk_lfxc_ledColorType)colorType
           colorProtocol:(nullable id <mk_lfxc_ledColorConfigProtocol>)protocol
            productModel:(mk_lfxc_productModel)productModel
                deviceID:(NSString *)deviceID
                   topic:(NSString *)topic
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备电量上报间隔
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readPowerReportIntervalWithDeviceID:(NSString *)deviceID
                                           topic:(NSString *)topic
                                        sucBlock:(void (^)(void))sucBlock
                                     failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置电量上报间隔
/// @param interval 1~600s
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configPowerReportInterval:(NSInteger)interval
                              deviceID:(NSString *)deviceID
                                 topic:(NSString *)topic
                              sucBlock:(void (^)(void))sucBlock
                           failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备电能存储参数
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readEnergyParamsWithDeviceID:(NSString *)deviceID
                                    topic:(NSString *)topic
                                 sucBlock:(void (^)(void))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置设备电能存储参数
/// @param interval 1min~60mins
/// @param powerChange 1%~100%
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configEnergyParams:(NSInteger)interval
                    powerChange:(NSInteger)powerChange
                       deviceID:(NSString *)deviceID
                          topic:(NSString *)topic
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// Read pulse constant.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_readPulseConstantWithDeviceID:(NSString *)deviceID
                                     topic:(NSString *)topic
                                  sucBlock:(void (^)(void))sucBlock
                               failedBlock:(void (^)(NSError *error))failedBlock;

/// Read hourly data for the day.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_readEnergyDataOfTodayWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// Read historical accumulated energy, up to 30 days of data
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_readHistoricalEnergyWithDeviceID:(NSString *)deviceID
                                        topic:(NSString *)topic
                                     sucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// Read the total accumulated energy.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_readTotalEnergyWithDeviceID:(NSString *)deviceID
                                   topic:(NSString *)topic
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// Reset energy consumption.
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_resetAccumulatedEnergyWithDeviceID:(NSString *)deviceID
                                          topic:(NSString *)topic
                                       sucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置开关状态上报间隔
/// @param interval 1~600s
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configSwitchStatusReportInterval:(NSInteger)interval
                                     deviceID:(NSString *)deviceID
                                        topic:(NSString *)topic
                                     sucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取开关状态上报间隔
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readSwitchStatusReportIntervalWithDeviceID:(NSString *)deviceID
                                                  topic:(NSString *)topic
                                               sucBlock:(void (^)(void))sucBlock
                                            failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置过载保护参数
/// @param isOn 过载保护是否打开
/// @param powerThreshold 过载保护值,欧法:10~4416w,美规:10~2160w,英规10~3588w
/// @param timeThreshold 判断过载的时间(超过过载保护值多长时间判定过载),1s~30s
/// @param productModel 产品规格
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configOverLoadParams:(BOOL)isOn
                   powerThreshold:(NSInteger)powerThreshold
                    timeThreshold:(NSInteger)timeThreshold
                     productModel:(mk_lfxc_productModel)productModel
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取过载保护参数
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readOverLoadParamsWithDeviceID:(NSString *)deviceID
                                      topic:(NSString *)topic
                                   sucBlock:(void (^)(void))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock;

/// 清除过载状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_clearOverLoadStatusWithDeviceID:(NSString *)deviceID
                                       topic:(NSString *)topic
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

/// 查询过载状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readOverLoadStatusWithDeviceID:(NSString *)deviceID
                                      topic:(NSString *)topic
                                   sucBlock:(void (^)(void))sucBlock
                                failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置过压保护参数
/// @param isOn 过压保护是否打开
/// @param voltageThreshold 过压保护值,欧法:200~264V,美规:100~138V,英规:200~264V
/// @param timeThreshold 判断过压的时间(超过过压保护值多长时间判定过载),1s~30s
/// @param productModel 产品规格
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configOverVoltageParams:(BOOL)isOn
                    voltageThreshold:(NSInteger)voltageThreshold
                       timeThreshold:(NSInteger)timeThreshold
                        productModel:(mk_lfxc_productModel)productModel
                            deviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取过压保护参数
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readOverVoltageParamsWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 清除过压状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_clearOverVoltageStatusWithDeviceID:(NSString *)deviceID
                                          topic:(NSString *)topic
                                       sucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// 查询过压状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readOverVoltageStatusWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置过流保护参数
/// @param isOn 过流保护是否打开
/// @param currentThreshold 过流保护值,欧法:0.1A~19.2A,美规:0.1~18A,英规0.1~15.6A
/// @param timeThreshold 判断过流的时间(超过过流保护值多长时间判定过载),1s~30s
/// @param productModel 产品规格
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configOverCurrentParams:(BOOL)isOn
                    currentThreshold:(double)currentThreshold
                       timeThreshold:(NSInteger)timeThreshold
                        productModel:(mk_lfxc_productModel)productModel
                            deviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取过流保护参数
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readOverCurrentParamsWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 清除过流状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_clearOverCurrentStatusWithDeviceID:(NSString *)deviceID
                                          topic:(NSString *)topic
                                       sucBlock:(void (^)(void))sucBlock
                                    failedBlock:(void (^)(NSError *error))failedBlock;

/// 查询过流状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readOverCurrentStatusWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置NTP服务器参数
/// @param isOn 是否打开NTP同步时间功能
/// @param domain NTP地址,0~64个ascii字符
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configNTPServer:(BOOL)isOn
                      domain:(NSString *)domain
                    deviceID:(NSString *)deviceID
                       topic:(NSString *)topic
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// 查询NTP服务器参数
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readNTPServerParamsWithDeviceID:(NSString *)deviceID
                                       topic:(NSString *)topic
                                    sucBlock:(void (^)(void))sucBlock
                                 failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置负载变化通知开关
/// @param removeIsOn 移除负载是否通知
/// @param accessIsOn 接入负载是否通知
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_ConfigLoadChangeStatus:(BOOL)removeIsOn
                         accessIsOn:(BOOL)accessIsOn
                           deviceID:(NSString *)deviceID
                              topic:(NSString *)topic
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取负载变化通知开关
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readLoadChangeStatusWithDeviceID:(NSString *)deviceID
                                        topic:(NSString *)topic
                                     sucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置RC模式下指示灯开关状态
/// @param powerIsOn 电源指示灯状态
/// @param networkIsOn 网络指示灯状态
/// @param deviceID deviecID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configRCLedStatus:(BOOL)powerIsOn
                   networkIsOn:(BOOL)networkIsOn
                      deviceID:(NSString *)deviceID
                         topic:(NSString *)topic
                      sucBlock:(void (^)(void))sucBlock
                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取RC模式下指示灯开关状态
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readRCLedStatusWithDeviceID:(NSString *)deviceID
                                   topic:(NSString *)topic
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

/// 设置服务器重连超时时间
/// @param timeout 0~1440mins
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configConnectionTimeout:(NSInteger)timeout
                            deviceID:(NSString *)deviceID
                               topic:(NSString *)topic
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取服务器重连超时时间
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readConnectionTimeoutWithDeviceID:(NSString *)deviceID
                                         topic:(NSString *)topic
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备时间
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readDeviceTimeWithDeviceID:(NSString *)deviceID
                                  topic:(NSString *)topic
                               sucBlock:(void (^)(void))sucBlock
                            failedBlock:(void (^)(NSError *error))failedBlock;

/// 读取设备MQTT参数
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_readDeviceMQTTParamsWithDeviceID:(NSString *)deviceID
                                        topic:(NSString *)topic
                                     sucBlock:(void (^)(void))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备的UTC时区，设备会按照该时区重新设置时间
/// @param timeZone -24~24(时区以30分钟为单位,-12~+12)
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configDeviceTimeZone:(NSInteger)timeZone
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
