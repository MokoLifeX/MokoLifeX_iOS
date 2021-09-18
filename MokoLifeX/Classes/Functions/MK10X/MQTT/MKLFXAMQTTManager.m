//
//  MKLFXAMQTTManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAMQTTManager.h"

#import "MKLFXServerManager.h"

NSString *const MKLFXAReceiveSwitchStateNotification = @"MKLFXAReceiveSwitchStateNotification";
NSString *const MKLFXAReceiveFirmwareInfoNotification = @"MKLFXAReceiveFirmwareInfoNotification";
NSString *const MKLFXAReceiveDelayTimeNotification = @"MKLFXAReceiveDelayTimeNotification";
NSString *const MKLFXAReceiveUpdateResultNotification = @"MKLFXAReceiveUpdateResultNotification";
NSString *const MKLFXAReceiveElectricityNotification = @"MKLFXAReceiveElectricityNotification";
NSString *const MKLFXAReceiveDevicePowerOnStatusNotification = @"MKLFXAReceiveDevicePowerOnStatusNotification";


static MKLFXAMQTTManager *manager = nil;
static dispatch_once_t onceToken;

@implementation MKLFXAMQTTManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKLFXServerManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKLFXAMQTTManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXAMQTTManager new];
        }
    });
    return manager;
}

+ (void)singleDealloc {
    [[MKLFXServerManager shared] removeDataManager:self];
    onceToken = 0;
    manager = nil;
}

#pragma mark - MKLFXServerManagerProtocol
- (void)lfx_didReceiveMessage:(NSDictionary *)data onTopic:(NSString *)topic {
    if ([self.delegate respondsToSelector:@selector(lfxa_deviceOnline:)]) {
        [self.delegate lfxa_deviceOnline:data[@"id"]];
    }
    NSString *notificationName = [self fetchNotificationNameWithMsgID:[data[@"msg_id"] integerValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:data];
}

- (void)lfx_didChangeState:(MKLFXMQTTSessionManagerState)newState {
    
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

- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKLFXServerManager shared] sendData:data
                                    topic:topic
                                 sucBlock:sucBlock
                              failedBlock:failedBlock];
}

#pragma mark - private method
- (NSString *)fetchNotificationNameWithMsgID:(NSInteger)msgID {
    if (msgID == 1001) {
        //开关状态
        return MKLFXAReceiveSwitchStateNotification;
    }
    if (msgID == 1002) {
        //固件信息
        return MKLFXAReceiveFirmwareInfoNotification;
    }
    if (msgID == 1003) {
        //倒计时
        return MKLFXAReceiveDelayTimeNotification;
    }
    if (msgID == 1004) {
        //固件升级结果
        return MKLFXAReceiveUpdateResultNotification;
    }
    if (msgID == 1006) {
        //电量信息
        return MKLFXAReceiveElectricityNotification;
    }
    if (msgID == 1008) {
        //读取插座上电默认开关状态
        return MKLFXAReceiveDevicePowerOnStatusNotification;
    }
    return @"";
}

@end
