//
//  MKLFXBMQTTManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/27.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBMQTTManager.h"

#import "MKLFXServerManager.h"

NSString *const MKLFXBReceiveSwitchStateNotification = @"MKLFXBReceiveSwitchStateNotification";
NSString *const MKLFXBReceiveDelayTimeNotification = @"MKLFXBReceiveDelayTimeNotification";
NSString *const MKLFXBReceiveElectricityNotification = @"MKLFXBReceiveElectricityNotification";
NSString *const MKLFXBReceiveFirmwareInfoNotification = @"MKLFXBReceiveFirmwareInfoNotification";
NSString *const MKLFXBReceiveUpdateResultNotification = @"MKLFXBReceiveUpdateResultNotification";
NSString *const MKLFXBReceiveDevicePowerOnStatusNotification = @"MKLFXBReceiveDevicePowerOnStatusNotification";
NSString *const MKLFXBReceiveOverloadNotification = @"MKLFXBReceiveOverloadNotification";
NSString *const MKLFXBReceivePowerReportPeriodNotification = @"MKLFXBReceivePowerReportPeriodNotification";
NSString *const MKLFXBReceiveEnergyReportPeriodNotification = @"MKLFXBReceiveEnergyReportPeriodNotification";
NSString *const MKLFXBReceiveStorageParametersNotification = @"MKLFXBReceiveStorageParametersNotification";
NSString *const MKLFXBReceiveLEDColorNotification = @"MKLFXBReceiveLEDColorNotification";
NSString *const MKLFXBReceiveHistoricalEnergyNotification = @"MKLFXBReceiveHistoricalEnergyNotification";
NSString *const MKLFXBReceiveEnergyDataOfTodayNotification = @"MKLFXBReceiveEnergyDataOfTodayNotification";
NSString *const MKLFXBReceivePulseConstantNotification = @"MKLFXBReceivePulseConstantNotification";
NSString *const MKLFXBReceiveTotalEnergyNotification = @"MKLFXBReceiveTotalEnergyNotification";
NSString *const MKLFXBReceiveCurrentEnergyNotification = @"MKLFXBReceiveCurrentEnergyNotification";
NSString *const MKLFXBLoadStatusChangedNotification = @"MKLFXBLoadStatusChangedNotification";

static MKLFXBMQTTManager *manager = nil;
static dispatch_once_t onceToken;

@implementation MKLFXBMQTTManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKLFXServerManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKLFXBMQTTManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXBMQTTManager new];
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
    if ([self.delegate respondsToSelector:@selector(lfxb_deviceOnline:)]) {
        [self.delegate lfxb_deviceOnline:data[@"id"]];
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
        return MKLFXBReceiveSwitchStateNotification;
    }
    if (msgID == 1002) {
        //固件信息
        return MKLFXBReceiveFirmwareInfoNotification;
    }
    if (msgID == 1003) {
        //倒计时
        return MKLFXBReceiveDelayTimeNotification;
    }
    if (msgID == 1004) {
        //固件升级结果
        return MKLFXBReceiveUpdateResultNotification;
    }
    if (msgID == 1005) {
        //载保护状态以及过载值
        return MKLFXBReceiveOverloadNotification;
    }
    if (msgID == 1006) {
        //电量信息
        return MKLFXBReceiveElectricityNotification;
    }
    if (msgID == 1008) {
        //读取插座上电默认开关状态
        return MKLFXBReceiveDevicePowerOnStatusNotification;
    }
    if (msgID == 1009) {
        //功率指示灯颜色
        return MKLFXBReceiveLEDColorNotification;
    }
    if (msgID == 1011) {
        //有负载接入
        return MKLFXBLoadStatusChangedNotification;
    }
    if (msgID == 1012) {
        //电量信息上报间隔
        return MKLFXBReceivePowerReportPeriodNotification;
    }
    if (msgID == 1013) {
        //累计电能存储参数
        return MKLFXBReceiveStorageParametersNotification;
    }
    if (msgID == 1014) {
        //累计电能
        return MKLFXBReceiveHistoricalEnergyNotification;
    }
    if (msgID == 1015) {
        //今天电能
        return MKLFXBReceiveEnergyDataOfTodayNotification;
    }
    if (msgID == 1016) {
        //脉冲常数
        return MKLFXBReceivePulseConstantNotification;
    }
    if (msgID == 1017) {
        //总累计电能
        return MKLFXBReceiveTotalEnergyNotification;
    }
    if (msgID == 1018) {
        //当前电能数据
        return MKLFXBReceiveCurrentEnergyNotification;
    }
    if (msgID == 1019) {
        //电能上报间隔
        return MKLFXBReceiveEnergyReportPeriodNotification;
    }
    return @"";
}

@end
