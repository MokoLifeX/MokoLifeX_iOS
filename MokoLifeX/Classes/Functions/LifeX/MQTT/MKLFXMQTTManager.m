//
//  MKLFXMQTTManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/28.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXMQTTManager.h"

#import "MKMacroDefines.h"

#import "MKLFXServerManager.h"

NSString *const MKLFXMQTTManagerStateChangedNotification = @"MKLFXMQTTManagerStateChangedNotification";

NSString *const MKLFXReceiveDeviceOnlineStateNotification = @"MKLFXReceiveDeviceOnlineStateNotification";

NSString *const MKLFXReceivedSwitchStateNotification = @"MKLFXReceivedSwitchStateNotification";

static MKLFXMQTTManager *manager = nil;
static dispatch_once_t onceToken;

@implementation MKLFXMQTTManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKLFXServerManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKLFXMQTTManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXMQTTManager new];
        }
    });
    return manager;
}

+ (void)singleDealloc {
    [[MKLFXServerManager shared] removeDataManager:manager];
    onceToken = 0;
    manager = nil;
}

#pragma mark - MKLFXServerManagerProtocol
- (void)lfx_didReceiveMessage:(NSDictionary *)data onTopic:(NSString *)topic {
    if (!ValidDict(data) || !ValidStr(topic)) {
        return;
    }
    NSInteger msgID = [data[@"msg_id"] integerValue];
    if (msgID == 1001) {
        //开关状态
        [[NSNotificationCenter defaultCenter] postNotificationName:MKLFXReceivedSwitchStateNotification
                                                            object:nil
                                                          userInfo:data];
        return;
    }
    //先抛出设备在线的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:MKLFXReceiveDeviceOnlineStateNotification
                                                        object:nil
                                                      userInfo:@{
        @"deviceID":data[@"id"]
    }];
}

- (void)lfx_didChangeState:(MKLFXMQTTSessionManagerState)newState {
    [[NSNotificationCenter defaultCenter] postNotificationName:MKLFXMQTTManagerStateChangedNotification
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - public method
- (NSString *)currentSubscribeTopic {
    return [MKLFXServerManager shared].serverParams.subscribeTopic;
}

- (NSString *)currentPublishedTopic {
    return [MKLFXServerManager shared].serverParams.publishTopic;
}

- (void)subscriptions:(NSArray <NSString *>*)topicList {
    [[MKLFXServerManager shared] subscriptions:topicList];
}

- (void)unsubscriptions:(NSArray <NSString *>*)topicList {
    [[MKLFXServerManager shared] unsubscriptions:topicList];
}

- (MKLFXMQTTSessionManagerState)state {
    return [MKLFXServerManager shared].state;
}

- (BOOL)MQTTParams {
    return ValidStr([MKLFXServerManager shared].serverParams.host);
}

- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKLFXServerManager shared] sendData:data
                                    topic:topic
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

@end
