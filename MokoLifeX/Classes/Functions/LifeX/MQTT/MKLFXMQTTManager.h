//
//  MKLFXMQTTManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/28.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXServerConfigDefines.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MKLFXMQTTManagerStateChangedNotification;
//任何一条数据都会说明当前设备在线
extern NSString *const MKLFXReceiveDeviceOnlineStateNotification;
//当收到设备开关状态的数据时，只会抛出MKLFXReceivedSwitchStateNotification，不会抛出MKLFXReceiveDeviceOnlineStateNotification
extern NSString *const MKLFXReceivedSwitchStateNotification;

@interface MKLFXMQTTManager : NSObject<MKLFXServerManagerProtocol>

@property (nonatomic, assign, readonly)MKLFXMQTTSessionManagerState state;

/// 查看本地是否已经有了app的MQTT信息
@property (nonatomic, assign, readonly)BOOL MQTTParams;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentSubscribeTopic)NSString *subscribeTopic;

/// 当前用户有没有设置MQTT的订阅topic，如果设置了，则只能定于这个topic，如果没有设置，则订阅添加的设备的topic
@property (nonatomic, copy, readonly, getter=currentPublishedTopic)NSString *publishedTopic;


+ (MKLFXMQTTManager *)shared;

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
