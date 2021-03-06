//
//  MKMQTTServerDataManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 mqtt服务器连接状态改变
 */
extern NSString *const MKMQTTSessionManagerStateChangedNotification;

/*
任何一条开关的通知都可以认为设备在线
*/
extern NSString *const MKMQTTServerReceivedDeviceOnlineNotification;

/*
 接收到开关状态的通知
 */
extern NSString *const MKMQTTServerReceivedSwitchStateNotification;

/*
 接收到倒计时的通知
 */
extern NSString *const MKMQTTServerReceivedDelayTimeNotification;

/*
 接收到电量信息通知
 */
extern NSString *const MKMQTTServerReceivedElectricityNotification;

/*
 接收到设备固件信息通知
 */
extern NSString *const MKMQTTServerReceivedFirmwareInfoNotification;

/*
 接收到设备固件升级结果通知
 */
extern NSString *const MKMQTTServerReceivedUpdateResultNotification;

/*
接收到设备过载保护通知
*/
extern NSString *const MKMQTTServerReceivedOverloadNotification;

/*
 接受到设备上电默认开关状态通知
 */
extern NSString *const MKMQTTServerReceivedDevicePowerOnStatusNotification;

/*
接受到设备电量信息上报间隔通知
*/
extern NSString *const MKMQTTServerReceivedPowerReportPeriodNotification;

/*
接受到设备电能信息上报间隔通知
*/
extern NSString *const MKMQTTServerReceivedEnergyReportPeriodNotification;

/*
接受到设备累计电能存储参数通知
*/
extern NSString *const MKMQTTServerReceivedStorageParametersNotification;

/*
接受到功率指示灯颜色通知
*/
extern NSString *const MKMQTTServerReceivedLEDColorNotification;

/*
接受到历史每天累计电能通知
*/
extern NSString *const MKMQTTServerReceivedHistoricalEnergyNotification;

/*
 接收到当天时间段累计电能通知
 */
extern NSString *const MKMQTTServerReceivedEnergyDataOfTodayNotification;

/*
 接收到脉冲常数通知
 */
extern NSString *const MKMQTTServerReceivedPulseConstantNotification;

/*
 接收到总累计电能通知
 */
extern NSString *const MKMQTTServerReceivedTotalEnergyNotification;

/*
 接收到当前电能数据通知
 */
extern NSString *const MKMQTTServerReceivedCurrentEnergyNotification;

/*
接收到当前有负载接入或者移除通知
*/
extern NSString *const MKMQTTServerLoadStatusChangedNotification;

@class MKConfigServerModel;
@interface MKMQTTServerDataManager : NSObject

@property (nonatomic, strong, readonly)MKConfigServerModel *configServerModel;

@property (nonatomic, assign, readonly)MKMQTTSessionManagerState state;

+ (MKMQTTServerDataManager *)sharedInstance;

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model;

/**
 记录到本地
 */
- (void)synchronize;

/**
 连接mqtt server

 */
- (void)connectServer;

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData;

@end
