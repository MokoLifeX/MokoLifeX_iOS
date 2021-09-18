//
//  MKLFXAOVMDDataModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/21.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAOVMDDataModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXASocketInterface.h"

#import "MKLFXAOVMDHeaderViewModel.h"

@interface MKLFXAOVMDDataModel ()

@property (nonatomic, strong)dispatch_queue_t configQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKLFXAOVMDDataModel

#pragma mark - public method
- (NSString *)checkParams {
    NSString *headerMsg = [self.headerModel checkParams];
    if (ValidStr(headerMsg)) {
        return headerMsg;
    }
    if (self.headerModel.connectMode > 0) {
        if (!ValidStr(self.caFileName)) {
            return @"CA File cannot be empty.";
        }
        if (self.headerModel.connectMode == 2 && (!ValidStr(self.clientKeyName) || !ValidStr(self.clientCertName))) {
            return @"Client File cannot be empty.";
        }
    }
    if (!ValidStr(self.publishTopic) || self.publishTopic.length > 128 || ![self.publishTopic isAsciiString]) {
        return @"PublishTopic error";
    }
    if (!ValidStr(self.subscribeTopic) || self.subscribeTopic.length > 128 || ![self.subscribeTopic isAsciiString]) {
        return @"SubscribeTopic error";
    }
    return @"";
}

- (void)configDeviceWithWifiSSID:(NSString *)wifiSSID
                    wifiPassword:(NSString *)wifiPassword
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    dispatch_async(self.configQueue, ^{
        if (![self configMQTTServer]) {
            [self operationFailedBlockWithMsg:@"Config MQTT Server Failed" block:failedBlock];
            return;
        }
        if (self.headerModel.connectMode > 0) {
            if (![self configCACerts]) {
                [self operationFailedBlockWithMsg:@"Config CA Cert Failed" block:failedBlock];
                return;
            }
            if (self.headerModel.connectMode == 2) {
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
        if (![self configWifi:wifiSSID password:wifiPassword]) {
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

#pragma mark - interface
- (BOOL)configMQTTServer {
    __block BOOL success = NO;
    [[MKLFXASocketInterface shared] lfxa_configMQTTServerHost:self.headerModel.host
                                                         port:[self.headerModel.port integerValue]
                                                  connectMode:self.headerModel.connectMode
                                                          qos:self.headerModel.qos
                                                    keepalive:[self.headerModel.keepAlive integerValue]
                                                 cleanSession:self.headerModel.cleanSession
                                                     clientId:self.headerModel.clientID
                                                     username:self.headerModel.userName
                                                     password:self.headerModel.password
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
    [[MKLFXASocketInterface shared] lfxa_configSubscibeTopic:self.subscribeTopic
                                                publishTopic:self.publishTopic
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
    [[MKLFXASocketInterface shared] lfxa_configDeviceID:self.headerModel.deviceID
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

- (MKLFXAOVMDHeaderViewModel *)headerModel {
    if (!_headerModel) {
        _headerModel = [[MKLFXAOVMDHeaderViewModel alloc] init];
    }
    return _headerModel;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)configQueue {
    if (!_configQueue) {
        _configQueue = dispatch_queue_create("configDeviceSocketQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _configQueue;
}

@end
