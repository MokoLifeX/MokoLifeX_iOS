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
