//
//  MKLFXCDModifyServerModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDModifyServerModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXC117DMQTTNotifications.h"
#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTInterface+MKLFX117DAdd.h"

static NSString *const defaultSubTopic = @"{device_name}/{device_id}/app_to_device";
static NSString *const defaultPubTopic = @"{device_name}/{device_id}/device_to_app";

@implementation MKLFXCDUpdateMQTTServerModel

- (instancetype)initWithModifyServerModel:(MKLFXCDModifyServerModel *)serverModel {
    if (self = [self init]) {
        self.mqtt_host = SafeStr(serverModel.host);
        self.mqtt_port = [serverModel.port integerValue];
        self.clientID = SafeStr(serverModel.clientID);
        self.subscribeTopic = [serverModel currentSubscribeTopic];
        self.publishTopic = [serverModel currentPublishTopic];
        self.cleanSession = serverModel.cleanSession;
        self.qos = serverModel.qos;
        self.keepAlive = [serverModel.keepAlive integerValue];
        self.mqtt_userName = SafeStr(serverModel.userName);
        self.mqtt_password = SafeStr(serverModel.password);
        if (!serverModel.sslIsOn) {
            self.connect_mode = 0;
        }else {
            if (serverModel.certificate == 0) {
                self.connect_mode = 1;
            }else if (serverModel.certificate == 1) {
                self.connect_mode = 2;
            }else if (serverModel.certificate == 2) {
                self.connect_mode = 3;
            }
        }
        self.sslHost = SafeStr(serverModel.sslHost);
        self.sslPort = [serverModel.sslPort integerValue];
        self.caFilePath = SafeStr(serverModel.caFilePath);
        self.clientKeyPath = SafeStr(serverModel.clientKeyPath);
        self.clientCertPath = SafeStr(serverModel.clientCertPath);
        self.wifiSSID = SafeStr(serverModel.wifiSSID);
        self.wifiPassword = SafeStr(serverModel.wifiPassword);
    }
    return self;
}

@end


@interface MKLFXCDModifyServerModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, copy)NSString *deviceID;

@property (nonatomic, copy)NSString *macAddress;

@property (nonatomic, copy)NSString *topic;

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)void (^sucBlock)(void);

@property (nonatomic, copy)void (^failedBlock)(NSError *error);

@end

@implementation MKLFXCDModifyServerModel

- (void)dealloc {
    NSLog(@"MKLFXCDModifyServerModel销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
            if (!ValidStr(self.sslHost) || self.sslHost.length > 64) {
                return @"SSL Host error";
            }
            if (!ValidStr(self.sslPort) || [self.sslPort integerValue] < 0 || [self.sslPort integerValue] > 65535) {
                return @"SSL Port error";
            }
            if (!ValidStr(self.caFilePath) || self.caFilePath.length > 100) {
                return @"CA File cannot be empty.";
            }
            if (self.certificate == 2 && (!ValidStr(self.clientKeyPath) || self.clientKeyPath.length > 100 || !ValidStr(self.clientCertPath) || self.clientCertPath.length > 100)) {
                return @"Client File cannot be empty.";
            }
        }
    }
    if (!ValidStr(self.wifiSSID) || self.wifiSSID.length > 32 || ![self.wifiSSID isAsciiString]) {
        return @"Wifi ssid error";
    }
    if (self.wifiPassword.length > 64) {
        return @"Wifi password error";
    }
    return @"";
}

- (void)updateServerWithDeviceID:(NSString *)deviceID
                      macAddress:(NSString *)macAddress
                      deviceName:(NSString *)deviceName
                           topic:(NSString *)topic
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock {
    self.deviceID = deviceID;
    self.macAddress = macAddress;
    self.topic = topic;
    self.deviceName = deviceName;
    self.sucBlock = nil;
    self.sucBlock = sucBlock;
    self.failedBlock = nil;
    self.failedBlock = failedBlock;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDownloadDatasResult:)
                                                 name:MKLFXCReceiveModifyMQTTConfigNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveReconnectNetworkResult:)
                                                 name:MKLFXCReceiveReconnectNetworkMQTTConfigNotification
                                               object:nil];
    dispatch_async(self.readQueue, ^{
        NSString *msg = [self checkParams];
        if (ValidStr(msg)) {
            [self operationFailedBlockWithMsg:msg block:failedBlock];
            return;
        }
        if (![self configServerInfo]) {
            [self operationFailedBlockWithMsg:@"Config MQTT Server Error" block:failedBlock];
            return;
        }
    });
}

- (NSString *)currentSubscribeTopic {
    NSString *subTopic = @"";
    if ([self.subscribeTopic isEqualToString:defaultSubTopic]) {
        //用户使用默认的topic
        subTopic = [NSString stringWithFormat:@"%@/%@/%@",self.deviceName,self.deviceID,@"app_to_device"];
    }else {
        //用户修改了topic
        subTopic = self.subscribeTopic;
    }
    return subTopic;
}

- (NSString *)currentPublishTopic {
    NSString *pubTopic = @"";
    if ([self.publishTopic isEqualToString:defaultPubTopic]) {
        //用户使用默认的topic
        pubTopic = [NSString stringWithFormat:@"%@/%@/%@",self.deviceName,self.deviceID,@"device_to_app"];
    }else {
        //用户修改了topic
        pubTopic = self.publishTopic;
    }
    return pubTopic;
}

#pragma mark - interval
- (BOOL)configServerInfo {
    __block BOOL success = NO;
    MKLFXCDUpdateMQTTServerModel *serverModel = [[MKLFXCDUpdateMQTTServerModel alloc] initWithModifyServerModel:self];
    [MKLFXCMQTTInterface lfxc_configMQTTServer:serverModel deviceID:self.deviceID topic:self.topic sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - Notification
- (void)receiveDownloadDatasResult:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceID] || [userInfo[@"msg_id"] integerValue] != 1124) {
        return;
    }
    NSInteger result = [userInfo[@"data"][@"result"] integerValue];
    if (result != 1) {
        [self operationFailedBlockWithMsg:@"Update Failed" block:self.failedBlock];
        return;
    }
    [MKLFXCMQTTInterface lfxc_reconnectNetworkWithDeviceID:self.deviceID topic:self.topic sucBlock:^{
        
    } failedBlock:self.failedBlock];
}

- (void)receiveReconnectNetworkResult:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceID] || [userInfo[@"msg_id"] integerValue] != 1125) {
        return;
    }
    NSInteger result = [userInfo[@"data"][@"result"] integerValue];
    if (result != 1) {
        [self operationFailedBlockWithMsg:@"Update Failed" block:self.failedBlock];
        return;
    }
    moko_dispatch_main_safe(^{
        if (self.sucBlock) {
            self.sucBlock();
        }
    });
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"mqttServerParams"
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

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("mqttServerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end

