//
//  MKLFXAMQTTManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXServerConfigDefines.h"

NS_ASSUME_NONNULL_BEGIN

/*
 接收到开关状态的通知
 */
extern NSString *const MKLFXAReceiveSwitchStateNotification;

/*
 接收到设备固件信息通知
 */
extern NSString *const MKLFXAReceiveFirmwareInfoNotification;

/*
 接收到倒计时的通知
 */
extern NSString *const MKLFXAReceiveDelayTimeNotification;

/*
 接收到固件升级结果
 */
extern NSString *const MKLFXAReceiveUpdateResultNotification;

/*
 接收到电量信息通知
 */
extern NSString *const MKLFXAReceiveElectricityNotification;

/*
 接受到设备上电默认开关状态通知
 */
extern NSString *const MKLFXAReceiveDevicePowerOnStatusNotification;

@protocol MKLFXAMQTTManagerDeviceOnlineDelegate <NSObject>

- (void)lfxa_deviceOnline:(NSString *)deviceID;

@end

@interface MKLFXAMQTTManager : NSObject<MKLFXServerManagerProtocol>

@property (nonatomic, assign, readonly)MKLFXMQTTSessionManagerState state;

@property (nonatomic, weak)id <MKLFXAMQTTManagerDeviceOnlineDelegate>delegate;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentSubscribeTopic)NSString *subscribeTopic;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentPublishedTopic)NSString *publishedTopic;


+ (MKLFXAMQTTManager *)shared;

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
