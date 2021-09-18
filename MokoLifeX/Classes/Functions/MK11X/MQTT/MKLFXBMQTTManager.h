//
//  MKLFXBMQTTManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/27.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXServerConfigDefines.h"

NS_ASSUME_NONNULL_BEGIN

/*
 接收到开关状态的通知
 */
extern NSString *const MKLFXBReceiveSwitchStateNotification;

/*
 接收到倒计时的通知
 */
extern NSString *const MKLFXBReceiveDelayTimeNotification;

/*
 接收到电量信息通知
 */
extern NSString *const MKLFXBReceiveElectricityNotification;

/*
 接收到设备固件信息通知
 */
extern NSString *const MKLFXBReceiveFirmwareInfoNotification;

/*
 接收到设备固件升级结果通知
 */
extern NSString *const MKLFXBReceiveUpdateResultNotification;

/*
接收到设备过载保护通知
*/
extern NSString *const MKLFXBReceiveOverloadNotification;

/*
 接受到设备上电默认开关状态通知
 */
extern NSString *const MKLFXBReceiveDevicePowerOnStatusNotification;

/*
接受到设备电量信息上报间隔通知
*/
extern NSString *const MKLFXBReceivePowerReportPeriodNotification;

/*
接受到设备电能信息上报间隔通知
*/
extern NSString *const MKLFXBReceiveEnergyReportPeriodNotification;

/*
接受到设备累计电能存储参数通知
*/
extern NSString *const MKLFXBReceiveStorageParametersNotification;

/*
接受到功率指示灯颜色通知
*/
extern NSString *const MKLFXBReceiveLEDColorNotification;

/*
接受到历史每天累计电能通知
*/
extern NSString *const MKLFXBReceiveHistoricalEnergyNotification;

/*
 接收到当天时间段累计电能通知
 */
extern NSString *const MKLFXBReceiveEnergyDataOfTodayNotification;

/*
 接收到脉冲常数通知
 */
extern NSString *const MKLFXBReceivePulseConstantNotification;

/*
 接收到总累计电能通知
 */
extern NSString *const MKLFXBReceiveTotalEnergyNotification;

/*
 接收到当前电能数据通知
 */
extern NSString *const MKLFXBReceiveCurrentEnergyNotification;

/*
接收到当前有负载接入或者移除通知
*/
extern NSString *const MKLFXBLoadStatusChangedNotification;




@protocol MKLFXBMQTTManagerDeviceOnlineDelegate <NSObject>

- (void)lfxb_deviceOnline:(NSString *)deviceID;

@end

@interface MKLFXBMQTTManager : NSObject<MKLFXServerManagerProtocol>

@property (nonatomic, assign, readonly)MKLFXMQTTSessionManagerState state;

@property (nonatomic, weak)id <MKLFXBMQTTManagerDeviceOnlineDelegate>delegate;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentSubscribeTopic)NSString *subscribeTopic;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentPublishedTopic)NSString *publishedTopic;


+ (MKLFXBMQTTManager *)shared;

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
