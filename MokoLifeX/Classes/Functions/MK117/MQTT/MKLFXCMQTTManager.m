//
//  MKLFXCMQTTManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/8.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTManager.h"

#import "MKLFXServerManager.h"

NSString *const MKLFXCReceiveSwitchStateNotification = @"MKLFXCReceiveSwitchStateNotification";
NSString *const MKLFXCReceiveFirmwareInfoNotification = @"MKLFXCReceiveFirmwareInfoNotification";
NSString *const MKLFXCReceiveDelayTimeNotification = @"MKLFXCReceiveDelayTimeNotification";
NSString *const MKLFXCReceiveUpdateResultNotification = @"MKLFXCReceiveUpdateResultNotification";
NSString *const MKLFXCReceiveElectricityNotification = @"MKLFXCReceiveElectricityNotification";
NSString *const MKLFXCReceiveDevicePowerOnStatusNotification = @"MKLFXCReceiveDevicePowerOnStatusNotification";
NSString *const MKLFXCReceiveLEDColorNotification = @"MKLFXCReceiveLEDColorNotification";
NSString *const MKLFXCReceiveLoadChangeStatusNotification = @"MKLFXCReceiveLoadChangeStatusNotification";
NSString *const MKLFXCReceivePowerReportIntervalNotification = @"MKLFXCReceivePowerReportIntervalNotification";

NSString *const MKLFXCReceiveEnergyParamsNotification = @"MKLFXCReceiveEnergyParamsNotification";
NSString *const MKLFXCReceiveHistoricalEnergyNotification = @"MKLFXCReceiveHistoricalEnergyNotification";
NSString *const MKLFXCReceiveEnergyDataOfTodayNotification = @"MKLFXCReceiveEnergyDataOfTodayNotification";
NSString *const MKLFXCReceivePulseConstantNotification = @"MKLFXCReceivePulseConstantNotification";
NSString *const MKLFXCReceiveTotalEnergyNotification = @"MKLFXCReceiveTotalEnergyNotification";
NSString *const MKLFXCReceiveCurrentEnergyNotification = @"MKLFXCReceiveCurrentEnergyNotification";
NSString *const MKLFXCReceiveEnergyReportPeriodNotification = @"MKLFXCReceiveEnergyReportPeriodNotification";
NSString *const MKLFXCReceiveSwitchStatusReportIntervalNotification = @"MKLFXCReceiveSwitchStatusReportIntervalNotification";

NSString *const MKLFXCReceiveOverLoadParamsNotification = @"MKLFXCReceiveOverLoadParamsNotification";
NSString *const MKLFXCReceiveOverLoadStatusNotification = @"MKLFXCReceiveOverLoadStatusNotification";
NSString *const MKLFXCReceiveOverVoltageParamsNotification = @"MKLFXCReceiveOverVoltageParamsNotification";
NSString *const MKLFXCReceiveOverVoltageStatusNotification = @"MKLFXCReceiveOverVoltageStatusNotification";
NSString *const MKLFXCReceiveOverCurrentParamsNotification = @"MKLFXCReceiveOverCurrentParamsNotification";
NSString *const MKLFXCReceiveOverCurrentStatusNotification = @"MKLFXCReceiveOverCurrentStatusNotification";
NSString *const MKLFXCReceiveNTPParamsNotification = @"MKLFXCReceiveNTPParamsNotification";

NSString *const MKLFXCReceiveLoadChangeNoteStatusNotification = @"MKLFXCReceiveLoadChangeNoteStatusNotification";
NSString *const MKLFXCReceiveRCLEDStatusNotification = @"MKLFXCReceiveRCLEDStatusNotification";
NSString *const MKLFXCReceiveConnectionTimeoutSettingNotification = @"MKLFXCReceiveConnectionTimeoutSettingNotification";
NSString *const MKLFXCReceiveDeviceCurrentTimeNotification = @"MKLFXCReceiveDeviceCurrentTimeNotification";
NSString *const MKLFXCReceiveDeviceMQTTParamsNotification = @"MKLFXCReceiveDeviceMQTTParamsNotification";

static MKLFXCMQTTManager *manager = nil;
static dispatch_once_t onceToken;

@implementation MKLFXCMQTTManager

- (instancetype)init {
    if (self = [super init]) {
        [[MKLFXServerManager shared] loadDataManager:self];
    }
    return self;
}

+ (MKLFXCMQTTManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXCMQTTManager new];
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
    NSLog(@"接收到数据:%@",data);
    if ([self.delegate respondsToSelector:@selector(lfxc_deviceOnline:)]) {
        [self.delegate lfxc_deviceOnline:data[@"id"]];
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
        return MKLFXCReceiveSwitchStateNotification;
    }
    if (msgID == 1002) {
        //固件信息
        return MKLFXCReceiveFirmwareInfoNotification;
    }
    if (msgID == 1003) {
        //倒计时
        return MKLFXCReceiveDelayTimeNotification;
    }
    if (msgID == 1004) {
        //固件升级结果
        return MKLFXCReceiveUpdateResultNotification;
    }
    if (msgID == 1006) {
        //电量信息
        return MKLFXCReceiveElectricityNotification;
    }
    if (msgID == 1008) {
        //读取插座上电默认开关状态
        return MKLFXCReceiveDevicePowerOnStatusNotification;
    }
    if (msgID == 1009) {
        //功率指示灯颜色
        return MKLFXCReceiveLEDColorNotification;
    }
    if (msgID == 1011) {
        //插座发布负载变化状态
        return MKLFXCReceiveLoadChangeStatusNotification;
    }
    if (msgID == 1012) {
        //电量信息上报间隔
        return MKLFXCReceivePowerReportIntervalNotification;
    }
    if (msgID == 1013) {
        //累计电能存储参数
        return MKLFXCReceiveEnergyParamsNotification;
    }
    if (msgID == 1020) {
        //累计电能
        return MKLFXCReceiveHistoricalEnergyNotification;
    }
    if (msgID == 1015) {
        //今天电能
        return MKLFXCReceiveEnergyDataOfTodayNotification;
    }
    if (msgID == 1016) {
        //脉冲常数
        return MKLFXCReceivePulseConstantNotification;
    }
    if (msgID == 1017) {
        //总累计电能
        return MKLFXCReceiveTotalEnergyNotification;
    }
    if (msgID == 1018) {
        //当前电能数据
        return MKLFXCReceiveCurrentEnergyNotification;
    }
    if (msgID == 1019) {
        //电能上报间隔
        return MKLFXCReceiveEnergyReportPeriodNotification;
    }
    if (msgID == 1101) {
        //开关状态上报间隔
        return MKLFXCReceiveSwitchStatusReportIntervalNotification;
    }
    if (msgID == 1103) {
        //发布过载保护开关&保护值&判断时间
        return MKLFXCReceiveOverLoadParamsNotification;
    }
    if (msgID == 1105) {
        //发布过载状态
        return MKLFXCReceiveOverLoadStatusNotification;
    }
    if (msgID == 1107) {
        //发布过压保护开关&保护值&判断时间
        return MKLFXCReceiveOverVoltageParamsNotification;
    }
    if (msgID == 1109) {
        //发布过压状态
        return MKLFXCReceiveOverVoltageStatusNotification;
    }
    if (msgID == 1111) {
        //发布过流保护开关&保护值&判断时间
        return MKLFXCReceiveOverCurrentParamsNotification;
    }
    if (msgID == 1113) {
        //发布过流状态
        return MKLFXCReceiveOverCurrentStatusNotification;
    }
    if (msgID == 1115) {
        //发布NTP同步开关&域名
        return MKLFXCReceiveNTPParamsNotification;
    }
    if (msgID == 1117) {
        //负载变化通知开关
        return MKLFXCReceiveLoadChangeNoteStatusNotification;
    }
    if (msgID == 1119) {
        //RC模式下指示灯开关状态
        return MKLFXCReceiveRCLEDStatusNotification;
    }
    if (msgID == 1121) {
        //发布服务器重连超时时间
        return MKLFXCReceiveConnectionTimeoutSettingNotification;
    }
    if (msgID == 1122) {
        //发布设备时间
        return MKLFXCReceiveDeviceCurrentTimeNotification;
    }
    if (msgID == 1123) {
        //发布设备的MQTT参数
        return MKLFXCReceiveDeviceMQTTParamsNotification;
    }
    return @"";
}

@end
