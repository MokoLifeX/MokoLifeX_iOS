//
//  MKLFXASocketInterface.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXASocketInterface.h"

#import "MKLFXSocketManager.h"
#import "MKLFXSocketAdopter.h"
#import "MKLFXSocketDefines.h"

#import "MKLFXASocketTag.h"

static MKLFXASocketInterface *manager = nil;
static dispatch_once_t onceToken;


static NSInteger const certPackageDataLength = 200;

@interface MKLFXASocketInterface ()

@property (nonatomic, strong)dispatch_queue_t certQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@end

@implementation MKLFXASocketInterface

+ (MKLFXASocketInterface *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXASocketInterface new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    manager = nil;
    onceToken = 0;
}

- (BOOL)isConnected {
    return [MKLFXSocketManager shared].isConnected;
}

- (void)connectWithSucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKLFXSocketManager shared] connectWithHost:lfx_defaultHostIpAddress
                                            port:lfx_defaultPort
                                        sucBlock:sucBlock
                                     failedBlock:failedBlock];
}

- (void)disconnect {
    [[MKLFXSocketManager shared] disconnect];
}

#pragma mark - interface
- (void)lfxa_configMQTTServerHost:(NSString *)host
                             port:(NSInteger)port
                      connectMode:(lfxa_mqttServerConnectMode)mode
                              qos:(lfxa_mqttServerQosMode)qos
                        keepalive:(NSInteger)keepalive
                     cleanSession:(BOOL)clean
                         clientId:(NSString *)clientId
                         username:(NSString *)username
                         password:(NSString *)password
                         sucBlock:(void (^)(id returnData))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    if (![MKLFXSocketAdopter isValidatIP:host] && (host.length < 1 || host.length > 63)) {
        [self operationFailedBlockWithMsg:@"Host error" failedBlock:failedBlock];
        return;
    }
    if (port < 0 || port > 65535) {
        [self operationFailedBlockWithMsg:@"Port effective range : 0~65535" failedBlock:failedBlock];
        return;
    }
    if (keepalive < 10 || keepalive > 120) {
        [self operationFailedBlockWithMsg:@"Keep alive effective range : 10~120" failedBlock:failedBlock];
        return;
    }
    if (clientId && clientId.length > 64) {
        [self operationFailedBlockWithMsg:@"Client id error" failedBlock:failedBlock];
        return;
    }
    if (username.length > 256) {
        [self operationFailedBlockWithMsg:@"User name error" failedBlock:failedBlock];
        return;
    }
    if (password.length > 256) {
        [self operationFailedBlockWithMsg:@"Password error" failedBlock:failedBlock];
        return;
    }
    NSInteger qosNumber = 2;
    if (qos == lfxa_mqttQosLevelAtMostOnce) {
        qosNumber = 0;
    }else if (qos == lfxa_mqttQosLevelAtLeastOnce){
        qosNumber = 1;
    }
    NSInteger connectModel = 0;
    if (mode == lfxa_mqttServerConnectOneWaySSLMode) {
        connectModel = 1;
    }else if (mode == lfxa_mqttServerConnectTwoWaySSLMode) {
        connectModel = 3;
    }
    NSDictionary *json = @{
        @"header":@(4002),
        @"host":host,
        @"port":@(port),
        @"clientId":(clientId ? clientId : @""),
        @"connect_mode":@(connectModel),
        @"username":(!username ? @"" : username),
        @"password":(!password ? @"" : password),
        @"keepalive":@(keepalive),
        @"qos":@(qosNumber),
        @"clean_session":(clean ? @(1) : @(0)),
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxa_socket_configMQTTServerTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

- (void)lfxa_configCACertificate:(NSData *)certificate
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidData(certificate)) {
        [self operationFailedBlockWithMsg:@"Certificate cann't be empty." failedBlock:failedBlock];
        return;
    }
    [self sendCertDataToDevice:certificate
                          type:1
                      sucBlock:sucBlock
                   failedBlock:failedBlock];
}

- (void)lfxa_configClientCertificate:(NSData *)certificate
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidData(certificate)) {
        [self operationFailedBlockWithMsg:@"Certificate cann't be empty." failedBlock:failedBlock];
        return;
    }
    [self sendCertDataToDevice:certificate
                          type:2
                      sucBlock:sucBlock
                   failedBlock:failedBlock];
}

- (void)lfxa_configClientKey:(NSData *)clientKey
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidData(clientKey)) {
        [self operationFailedBlockWithMsg:@"Client key cann't be empty." failedBlock:failedBlock];
        return;
    }
    [self sendCertDataToDevice:clientKey
                          type:3
                      sucBlock:sucBlock
                   failedBlock:failedBlock];
}

- (void)lfxa_configSubscibeTopic:(NSString *)subscibeTopic
                    publishTopic:(NSString *)publishTopic
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidStr(subscibeTopic) || subscibeTopic.length > 128
        || !MKSKValidStr(publishTopic) || publishTopic.length > 128) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *json = @{
        @"header":@(4004),
        @"set_publish_topic":publishTopic,
        @"set_subscibe_topic":(subscibeTopic),
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxa_socket_configTopicTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

- (void)lfxa_configElectricalDefaultState:(lfxa_electricalDefaultState)state
                                 sucBlock:(void (^)(id returnData))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock {
    NSDictionary *json = @{
        @"header":@(4005),
        @"switch_status":@(state),
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxa_socket_configElectricalDefaultStateTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

- (void)lfxa_configWifiSSID:(NSString *)ssid
                   password:(NSString *)password
                   security:(lfxa_wifiSecurity)security
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidStr(ssid) || ssid.length > 32 || password.length > 64) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    NSInteger wifi_security = 0;
    if (security == lfxa_wifiSecurity_WEP) {
        wifi_security = 1;
    }else if (security == lfxa_wifiSecurity_WPA_PSK){
        wifi_security = 2;
    }else if (security == lfxa_wifiSecurity_WPA2_PSK){
        wifi_security = 3;
    }else if (security == lfxa_wifiSecurity_WPA_WPA2_PSK){
        wifi_security = 4;
    }
    NSDictionary *json = @{
        @"header":@(4006),
        @"wifi_ssid":ssid,
        @"wifi_pwd":((!password || password.length == 0) ? @"" : password),
        @"wifi_security":@(wifi_security),
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxa_socket_configWifiParamsTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

- (void)lfxa_configDeviceID:(NSString *)deviceID
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidStr(deviceID) || deviceID.length > 32) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *json = @{
        @"header":@(4007),
        @"id":deviceID,
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxa_socket_configDeviceIDTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

#pragma mark - cert
- (void)sendCertDataToDevice:(NSData *)certData
                        type:(NSInteger)type
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    dispatch_async(self.certQueue, ^{
        NSInteger reminder = (certData.length % certPackageDataLength);
        NSInteger totalPackages = (reminder ? ((certData.length / certPackageDataLength) + 1) : (certData.length / certPackageDataLength));
        for (NSInteger i = 0; i < totalPackages; i ++) {
            //正常数据发送
            NSInteger len = certPackageDataLength;
            if (i == totalPackages - 1) {
                len = certData.length % certPackageDataLength;
            }
            NSData *tempData = [certData subdataWithRange:NSMakeRange(i * certPackageDataLength, len)];
            NSString *subData = [[NSString alloc] initWithData:tempData encoding:NSUTF8StringEncoding];
            if (!MKSKValidStr(subData)) {
                [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
                return;
            }
            NSDictionary *json = @{
                @"header":@(4003),
                @"file_type":@(type),
                @"file_size":@(certData.length),
                @"current_packet_len":@(subData.length),
                @"data":subData,
                @"offset":@(i * certPackageDataLength),
            };
            NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
            if (![self sendCertData:jsonString]) {
                [self operationFailedBlockWithMsg:@"Send Failed" failedBlock:failedBlock];
                return;
            }
        }
        MKSKBase_main_safe(^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (BOOL)sendCertData:(NSString *)data {
    __block BOOL success = NO;
    [[MKLFXSocketManager shared] addTaskWithTag:lfxa_socket_configCertDataTag data:data sucBlock:^(id  _Nonnull returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.MKSocketInterface"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    MKSKBase_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)certQueue {
    if (!_certQueue) {
        _certQueue = dispatch_queue_create("certQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _certQueue;
}

@end
