//
//  MKLFXCDServerForDeviceModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDServerForDeviceModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXServerManager.h"

#import "MKLFXCSocketInterface.h"
#import "MKLFXCSocketInterface+MKLFX117DAdd.h"

static NSString *const defaultSubTopic = @"{device_name}/{device_id}/app_to_device";
static NSString *const defaultPubTopic = @"{device_name}/{device_id}/device_to_app";

@interface MKLFXCDServerForDeviceModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKLFXCDServerForDeviceModel

- (instancetype)init {
    if (self = [super init]) {
        _host = [MKLFXServerManager shared].serverParams.host;
        _port = [MKLFXServerManager shared].serverParams.port;
        _subscribeTopic = defaultSubTopic;
        _publishTopic = defaultPubTopic;
        _cleanSession = YES;
        _keepAlive = @"60";
        _qos = 1;
    }
    return self;
}

- (NSString *)checkParams {
    if (!ValidStr(self.host) || self.host.length > 64 || ![self.host isAsciiString]) {
        return @"Host error";
    }
    if (!ValidStr(self.port) || [self.port integerValue] < 0 || [self.port integerValue] > 65535) {
        return @"Port error";
    }
    if (!ValidStr(self.clientID) || self.clientID.length > 64 || ![self.clientID isAsciiString]) {
        return @"ClientID error";
    }
    if (!ValidStr(self.publishTopic) || self.publishTopic.length > 128 || ![self.publishTopic isAsciiString]) {
        return @"PublishTopic error";
    }
    if (!ValidStr(self.subscribeTopic) || self.subscribeTopic.length > 128 || ![self.subscribeTopic isAsciiString]) {
        return @"SubscribeTopic error";
    }
    if (self.qos < 0 || self.qos > 2) {
        return @"Qos error";
    }
    if (!ValidStr(self.keepAlive) || [self.keepAlive integerValue] < 10 || [self.keepAlive integerValue] > 120) {
        return @"KeepAlive error";
    }
    if (self.userName.length > 256 || (ValidStr(self.userName) && ![self.userName isAsciiString])) {
        return @"UserName error";
    }
    if (self.password.length > 256 || (ValidStr(self.password) && ![self.password isAsciiString])) {
        return @"Password error";
    }
    if (self.sslIsOn) {
        if (self.certificate < 0 || self.certificate > 2) {
            return @"Certificate error";
        }
        if (self.certificate > 0) {
            if (!ValidStr(self.caFileName)) {
                return @"CA File cannot be empty.";
            }
            if (self.certificate == 2 && (!ValidStr(self.clientKeyName) || !ValidStr(self.clientCertName))) {
                return @"Client File cannot be empty.";
            }
        }
    }
    if (!ValidStr(self.deviceID) || self.deviceID.length > 32 || ![self.deviceID isAsciiString]) {
        return @"DeviceID error";
    }
    if (self.ntpHost.length > 64 || (ValidStr(self.ntpHost) && ![self.ntpHost isAsciiString])) {
        return @"NTP URL error";
    }
    if (self.timeZone < 0 || self.timeZone > 52) {
        return @"TimeZone error";
    }
    if (self.domain < 0 || self.domain > 21) {
        return @"Domain error";
    }
    return @"";
}

- (void)readDataWithSucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self readChannel]) {
            [self operationFailedBlockWithMsg:@"Read Channel Failed" block:failedBlock];
            return;
        }
        if (![self readTimeZone]) {
            [self operationFailedBlockWithMsg:@"Read Time Zone Failed" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (void)configParamsWithWifiSSID:(NSString *)ssid
                        password:(NSString *)password
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![MKLFXCSocketInterface shared].isConnected) {
            if (![self connectDevice]) {
                [self operationFailedBlockWithMsg:@"Connect Device Failed" block:failedBlock];
                return;
            }
        }
        if (![self configMQTTServer]) {
            [self operationFailedBlockWithMsg:@"Config MQTT Server Failed" block:failedBlock];
            return;
        }
        if (self.sslIsOn && self.certificate > 0) {
            if (![self configCACerts]) {
                [self operationFailedBlockWithMsg:@"Config CA Cert Failed" block:failedBlock];
                return;
            }
            if (self.certificate == 2) {
                if (![self configClientKey]) {
                    [self operationFailedBlockWithMsg:@"Config Client Key Failed" block:failedBlock];
                    return;
                }
                if (![self configClientCerts]) {
                    [self operationFailedBlockWithMsg:@"Config Client Certs Failed" block:failedBlock];
                    return;
                }
            }
        }
        if (![self configTopics]) {
            [self operationFailedBlockWithMsg:@"Config Topics Failed" block:failedBlock];
            return;
        }
        if (![self configDeviceID]) {
            [self operationFailedBlockWithMsg:@"Config DeviceID Failed" block:failedBlock];
            return;
        }
        if (![self configNTP]) {
            [self operationFailedBlockWithMsg:@"Config NTP Server Failed" block:failedBlock];
            return;
        }
        if (![self configTimeZone]) {
            [self operationFailedBlockWithMsg:@"Config Time Zone Failed" block:failedBlock];
            return;
        }
        if (![self configDomain]) {
            [self operationFailedBlockWithMsg:@"Config Channel & Domain Failed" block:failedBlock];
            return;
        }
        if (![self configWifi:ssid password:password]) {
            [self operationFailedBlockWithMsg:@"Config Wifi Info Failed" block:failedBlock];
            return;
        }
        moko_dispatch_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (NSString *)currentPublishTopic {
    NSString *publishTopic = @"";
    if ([self.publishTopic isEqualToString:defaultPubTopic]) {
        //用户使用默认的topic
        publishTopic = [NSString stringWithFormat:@"%@/%@/%@",self.deviceName,self.deviceID,@"device_to_app"];
    }else {
        //用户修改了topic
        publishTopic = self.publishTopic;
    }
    return publishTopic;
}

- (NSString *)currentSubscribeTopic {
    NSString *subscribeTopic = @"";
    if ([self.subscribeTopic isEqualToString:defaultSubTopic]) {
        //用户使用默认的topic
        subscribeTopic = [NSString stringWithFormat:@"%@/%@/%@",self.deviceName,self.deviceID,@"app_to_device"];
    }else {
        //用户修改了topic
        subscribeTopic = self.subscribeTopic;
    }
    return subscribeTopic;
}

#pragma mark - interface
- (BOOL)connectDevice {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] connectWithSucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readChannel {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_readChannelWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.domain = [returnData[@"result"][@"channel_plan"] integerValue];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readTimeZone {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_read117DTimeZoneWithSucBlock:^(id  _Nonnull returnData) {
        success = YES;
        self.timeZone = [returnData[@"result"][@"time_zone"] integerValue] + 24;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configMQTTServer {
    __block BOOL success = NO;
    lfxc_mqttServerConnectMode connectMode = lfxc_connectMode_TCP;
    if (self.sslIsOn) {
        if (self.certificate == 0) {
            connectMode = lfxc_connectMode_CASignedServerCertificate;
        }else if (self.certificate == 1) {
            connectMode = lfxc_connectMode_CACertificate;
        }else if (self.certificate == 2) {
            connectMode = lfxc_connectMode_SelfSignedCertificates;
        }
    }
    [[MKLFXCSocketInterface shared] lfxc_configMQTTServerHost:self.host
                                                         port:[self.port integerValue]
                                                  connectMode:connectMode
                                                          qos:self.qos
                                                    keepalive:[self.keepAlive integerValue]
                                                 cleanSession:self.cleanSession
                                                     clientId:self.clientID
                                                     username:self.userName
                                                     password:self.password
                                                     sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                                  failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configCACerts {
    __block BOOL success = NO;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.caFileName];
    NSData *caData = [NSData dataWithContentsOfFile:filePath];
    [[MKLFXCSocketInterface shared] lfxc_configCACertificate:caData
                                                    sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                                 failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientKey {
    __block BOOL success = NO;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.clientKeyName];
    NSData *clientKeyData = [NSData dataWithContentsOfFile:filePath];
    [[MKLFXCSocketInterface shared] lfxc_configClientKey:clientKeyData
                                                sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                             failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configClientCerts {
    __block BOOL success = NO;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.clientCertName];
    NSData *clientCertData = [NSData dataWithContentsOfFile:filePath];
    [[MKLFXCSocketInterface shared] lfxc_configClientCertificate:clientCertData
                                                        sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                                     failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configTopics {
    __block BOOL success = NO;
    NSString *subscribeTopic = [self currentSubscribeTopic];
    NSString *publishTopic = [self currentPublishTopic];
    [[MKLFXCSocketInterface shared] lfxc_configSubscibeTopic:subscribeTopic
                                                publishTopic:publishTopic
                                                    sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                                 failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDeviceID {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_configDeviceID:self.deviceID
                                               sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                            failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configWifi:(NSString *)ssid password:(NSString *)password {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_configWifiSSID:ssid
                                               password:password
                                               security:lfxc_wifiSecurity_WPA2_PSK
                                               sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                            failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configNTP {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_configNTPServer:SafeStr(self.ntpHost)
                                                sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                             failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configTimeZone {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_config117DTimeZone:(self.timeZone - 24)
                                                   sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                                failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configDomain {
    __block BOOL success = NO;
    [[MKLFXCSocketInterface shared] lfxc_configChannel:self.domain
                                              sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                           failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"serverParams"
                                                    code:-999
                                                userInfo:@{@"errorInfo":msg}];
        block(error);
    })
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("serverSettingsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

@end
