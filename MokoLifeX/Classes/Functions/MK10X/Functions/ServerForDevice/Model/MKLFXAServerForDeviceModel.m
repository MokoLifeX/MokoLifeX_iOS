//
//  MKLFXAServerForDeviceModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAServerForDeviceModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXASocketInterface.h"

static NSString *const defaultSubTopic = @"{device_name}/{device_id}/app_to_device";
static NSString *const defaultPubTopic = @"{device_name}/{device_id}/device_to_app";

@interface MKLFXAServerForDeviceModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKLFXAServerForDeviceModel

- (instancetype)init {
    if (self = [super init]) {
        _subscribeTopic = defaultSubTopic;
        _publishTopic = defaultPubTopic;
        _cleanSession = YES;
        _keepAlive = @"60";
        _qos = 1;
    }
    return self;
}

- (NSString *)checkParams {
    if (!ValidStr(self.host) || self.host.length > 63 || ![self.host isAsciiString]) {
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
    return @"";
}

- (void)configParamsWithWifiSSID:(NSString *)ssid
                        password:(NSString *)password
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![MKLFXASocketInterface shared].isConnected) {
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
            NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *filePath = [document stringByAppendingPathComponent:self.caFileName];
            NSData *caData = [NSData dataWithContentsOfFile:filePath];
            if (ValidData(caData)) {
                //判断当前是否有CA证书
                if (![self configCACerts:caData]) {
                    [self operationFailedBlockWithMsg:@"Config CA Cert Failed" block:failedBlock];
                    return;
                }
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
    [[MKLFXASocketInterface shared] connectWithSucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)configMQTTServer {
    __block BOOL success = NO;
    lfxa_mqttServerConnectMode connectMode = lfxa_mqttServerConnectTCPMode;
    if (self.sslIsOn) {
        if (self.certificate == 0 || self.certificate == 1) {
            connectMode = lfxa_mqttServerConnectOneWaySSLMode;
        }else if (self.certificate == 2) {
            connectMode = lfxa_mqttServerConnectTwoWaySSLMode;
        }
    }
    [[MKLFXASocketInterface shared] lfxa_configMQTTServerHost:self.host
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

- (BOOL)configCACerts:(NSData *)caData {
    __block BOOL success = NO;
    [[MKLFXASocketInterface shared] lfxa_configCACertificate:caData
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
    [[MKLFXASocketInterface shared] lfxa_configClientKey:clientKeyData
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
    [[MKLFXASocketInterface shared] lfxa_configClientCertificate:clientCertData
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
    [[MKLFXASocketInterface shared] lfxa_configSubscibeTopic:subscribeTopic
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
    [[MKLFXASocketInterface shared] lfxa_configDeviceID:self.deviceID
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
    [[MKLFXASocketInterface shared] lfxa_configWifiSSID:ssid
                                               password:password
                                               security:lfxa_wifiSecurity_WPA2_PSK
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
