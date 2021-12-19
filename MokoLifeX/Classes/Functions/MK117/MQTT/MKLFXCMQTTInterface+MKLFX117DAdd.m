//
//  MKLFXCMQTTInterface+MKLFX117DAdd.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTInterface+MKLFX117DAdd.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXCMQTTManager.h"

@implementation MKLFXCMQTTInterface (MKLFX117DAdd)

+ (void)lfxc_config117DDeviceTimeZone:(NSInteger)timeZone
                             deviceID:(NSString *)deviceID
                                topic:(NSString *)topic
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    if (timeZone < -24 || timeZone > 28) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2125),
                              @"id":deviceID,
                              @"data":@{
                                      @"timestamp":@((long long)[[NSDate date] timeIntervalSince1970]),
                                      @"time_zone":@(timeZone),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configMQTTServer:(id <lfxc_117d_updateMQTTServerProtocol>)protocol
                     deviceID:(NSString *)deviceID
                        topic:(NSString *)topic
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (![self checkMQTTServerProtocol:protocol]) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2126),
                              @"id":deviceID,
                              @"data":@{
                                  @"wifi_ssid":SafeStr(protocol.wifiSSID),
                                  @"wifi_passwd":SafeStr(protocol.wifiPassword),
                                  @"connect_mode":@(protocol.connect_mode),
                                  @"mqtt_host":SafeStr(protocol.mqtt_host),
                                  @"mqtt_port":@(protocol.mqtt_port),
                                  @"mqtt_username":SafeStr(protocol.mqtt_userName),
                                  @"mqtt_passwd":SafeStr(protocol.mqtt_password),
                                  @"clean_session":(protocol.cleanSession ? @(1) : @(0)),
                                  @"keep_alive":@(protocol.keepAlive),
                                  @"qos":@(protocol.qos),
                                  @"subscribe_topic":SafeStr(protocol.subscribeTopic),
                                  @"publish_topic":SafeStr(protocol.publishTopic),
                                  @"client_id":SafeStr(protocol.clientID),
                                  @"ssl_host":SafeStr(protocol.sslHost),
                                  @"ssl_port":@(protocol.sslPort),
                                  @"ca_way":SafeStr(protocol.caFilePath),
                                  @"client_cer_way":SafeStr(protocol.clientCertPath),
                                  @"client_key_way":SafeStr(protocol.clientKeyPath)
                              }
    };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_reconnectNetworkWithDeviceID:(NSString *)deviceID
                                    topic:(NSString *)topic
                                 sucBlock:(void (^)(void))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2127),
                              @"id":deviceID,
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

#pragma mark - private method
+ (BOOL)checkMQTTServerProtocol:(id <lfxc_117d_updateMQTTServerProtocol>)protocol {
    if (!protocol || ![protocol conformsToProtocol:@protocol(lfxc_117d_updateMQTTServerProtocol)]) {
        return NO;
    }
    if (!ValidStr(protocol.mqtt_host) || protocol.mqtt_host.length > 64 || ![protocol.mqtt_host isAsciiString]) {
        return NO;
    }
    if (protocol.mqtt_port < 0 || protocol.mqtt_port > 65535) {
        return NO;
    }
    if (!ValidStr(protocol.clientID) || protocol.clientID.length > 64 || ![protocol.clientID isAsciiString]) {
        return NO;
    }
    if (!ValidStr(protocol.publishTopic) || protocol.publishTopic.length > 128 || ![protocol.publishTopic isAsciiString]) {
        return NO;
    }
    if (!ValidStr(protocol.subscribeTopic) || protocol.subscribeTopic.length > 128 || ![protocol.subscribeTopic isAsciiString]) {
        return NO;
    }
    if (protocol.qos < 0 || protocol.qos > 2) {
        return NO;
    }
    if (protocol.keepAlive < 10 || protocol.keepAlive > 120) {
        return NO;
    }
    if (protocol.mqtt_userName.length > 256 || (ValidStr(protocol.mqtt_userName) && ![protocol.mqtt_userName isAsciiString])) {
        return NO;
    }
    if (protocol.mqtt_password.length > 256 || (ValidStr(protocol.mqtt_password) && ![protocol.mqtt_password isAsciiString])) {
        return NO;
    }
    if (protocol.connect_mode < 0 || protocol.connect_mode > 3) {
        return NO;
    }
    if (protocol.connect_mode == 2 || protocol.connect_mode == 3) {
        if (!ValidStr(protocol.sslHost) || protocol.sslHost.length > 64) {
            return NO;
        }
        if (protocol.sslPort < 0 || protocol.sslPort > 65535) {
            return NO;
        }
        if (!ValidStr(protocol.caFilePath) || protocol.caFilePath.length > 100) {
            return NO;
        }
        if (protocol.connect_mode == 3 && (!ValidStr(protocol.clientKeyPath) || protocol.clientKeyPath.length > 100 || !ValidStr(protocol.clientCertPath) || protocol.clientCertPath.length > 100)) {
            return NO;
        }
    }
    if (!ValidStr(protocol.wifiSSID) || protocol.wifiSSID.length > 32 || ![protocol.wifiSSID isAsciiString]) {
        return NO;
    }
    if (protocol.wifiPassword.length > 64 || ![protocol.wifiPassword isAsciiString]) {
        return NO;
    }
    return YES;
}

@end
