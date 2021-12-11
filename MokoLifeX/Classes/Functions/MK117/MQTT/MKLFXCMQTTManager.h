//
//  MKLFXCMQTTManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/8.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXServerConfigDefines.h"

NS_ASSUME_NONNULL_BEGIN

/*
 接收到开关状态的通知
 */
extern NSString *const MKLFXCReceiveSwitchStateNotification;

/*
 接收到设备固件信息通知
 */
extern NSString *const MKLFXCReceiveFirmwareInfoNotification;

/*
 接收到倒计时的通知
 */
extern NSString *const MKLFXCReceiveDelayTimeNotification;

/*
 接收到固件升级结果
 */
extern NSString *const MKLFXCReceiveUpdateResultNotification;

/*
 接收到电量信息通知
 */
extern NSString *const MKLFXCReceiveElectricityNotification;

/*
 接受到设备上电默认开关状态通知
 */
extern NSString *const MKLFXCReceiveDevicePowerOnStatusNotification;

/*
 接受到功率指示灯颜色通知
 */
extern NSString *const MKLFXCReceiveLEDColorNotification;

/*
 接收到负载变化通知
 */
extern NSString *const MKLFXCReceiveLoadChangeStatusNotification;

/*
 接收到电量信息上报间隔通知
 */
extern NSString *const MKLFXCReceivePowerReportIntervalNotification;

/*
 接收到累计电能存储参数通知
 */
extern NSString *const MKLFXCReceiveEnergyParamsNotification;

/*
接受到历史每天累计电能通知
*/
extern NSString *const MKLFXCReceiveHistoricalEnergyNotification;

/*
 接收到当天时间段累计电能通知
 */
extern NSString *const MKLFXCReceiveEnergyDataOfTodayNotification;

/*
 接收到脉冲常数通知
 */
extern NSString *const MKLFXCReceivePulseConstantNotification;

/*
 接收到总累计电能通知
 */
extern NSString *const MKLFXCReceiveTotalEnergyNotification;

/*
 接收到当前电能数据通知
 */
extern NSString *const MKLFXCReceiveCurrentEnergyNotification;

/*
接受到设备电能信息上报间隔通知
*/
extern NSString *const MKLFXCReceiveEnergyReportPeriodNotification;

/*
 接收到开关状态上报间隔通知
 */
extern NSString *const MKLFXCReceiveSwitchStatusReportIntervalNotification;

/*
 接收到过载保护开关&保护值&判断时间
 */
extern NSString *const MKLFXCReceiveOverLoadParamsNotification;

/*
 接收到过载状态通知
 */
extern NSString *const MKLFXCReceiveOverLoadStatusNotification;

/*
 接收到过压保护开关&保护值&判断时间
 */
extern NSString *const MKLFXCReceiveOverVoltageParamsNotification;

/*
 接收到过压状态
 */
extern NSString *const MKLFXCReceiveOverVoltageStatusNotification;

/*
 接收到过流保护开关&保护值&判断时间
 */
extern NSString *const MKLFXCReceiveOverCurrentParamsNotification;

/*
 接收到过流状态
 */
extern NSString *const MKLFXCReceiveOverCurrentStatusNotification;

/*
 接收到NTP同步开关&域名
 */
extern NSString *const MKLFXCReceiveNTPParamsNotification;

/*
 接收到负载变化通知开关通知
 */
extern NSString *const MKLFXCReceiveLoadChangeNoteStatusNotification;

/*
 接收到设备发布的RC模式下指示灯开关状态通知
 */
extern NSString *const MKLFXCReceiveRCLEDStatusNotification;

/*
 接收到设备发布的服务器重连超时时间通知
 */
extern NSString *const MKLFXCReceiveConnectionTimeoutSettingNotification;

/*
 接收到设备发布的当前时间通知
 */
extern NSString *const MKLFXCReceiveDeviceCurrentTimeNotification;

/*
 接收到设备发布的MQTT参数通知
 */
extern NSString *const MKLFXCReceiveDeviceMQTTParamsNotification;

@protocol MKLFXCMQTTManagerDeviceOnlineDelegate <NSObject>

- (void)lfxc_deviceOnline:(NSString *)deviceID;

@end

@interface MKLFXCMQTTManager : NSObject<MKLFXServerManagerProtocol>

@property (nonatomic, assign, readonly)MKLFXMQTTSessionManagerState state;

@property (nonatomic, weak)id <MKLFXCMQTTManagerDeviceOnlineDelegate>delegate;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentSubscribeTopic)NSString *subscribeTopic;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentPublishedTopic)NSString *publishedTopic;


+ (MKLFXCMQTTManager *)shared;

+ (void)singleDealloc;

/**
 Subscribe the topic

 @param topicList topicList
 */
- (void)subscriptions:(NSArray <NSString *>*)topicList;

/**
 Unsubscribe the topic
 
 @param topicList topicList
 */
- (void)unsubscriptions:(NSArray <NSString *>*)topicList;

- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
