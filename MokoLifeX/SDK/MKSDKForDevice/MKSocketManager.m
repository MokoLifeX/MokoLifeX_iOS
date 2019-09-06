//
//  MKSocketManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSocketManager.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#import "MKSocketBlockAdopter.h"
#import "MKSocketAdopter.h"

#import "MKSocketTaskOperation.h"

//设备默认的ip地址
NSString *const defaultHostIpAddress = @"192.168.4.1";
//设备默认的端口号
NSInteger const defaultPort = 8266;

static NSInteger const certPackageDataLength = 200;

static NSTimeInterval const defaultConnectTime = 15.f;
static NSTimeInterval const defaultCommandTime = 2.f;

@interface MKSocketManager()<GCDAsyncSocketDelegate>

@property (nonatomic, strong)GCDAsyncSocket *socket;

@property (nonatomic, strong)dispatch_queue_t socketQueue;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@property (nonatomic, copy)void (^connectSucBlock)(NSString *IP, NSInteger port);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

/**
 连接定时器，超过指定时间将会视为连接失败
 */
@property (nonatomic, strong)dispatch_source_t connectTimer;

/**
 连接超时标记
 */
@property (nonatomic, assign)BOOL connectTimeout;

@property (nonatomic, strong)dispatch_queue_t certQueue;

@end

@implementation MKSocketManager

#pragma mark - life circle

+ (MKSocketManager *)sharedInstance{
    static MKSocketManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [self socketManager];
        }
    });
    return manager;
}

+ (MKSocketManager *)socketManager{
    return [[self alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        _socketQueue = dispatch_queue_create("com.moko.MKSocketManagerQueue", nil);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

#pragma mark - delegate

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if (!sock || self.connectTimeout) {
        return;
    }
    [self.operationQueue cancelAllOperations];
    self.connectTimeout = NO;
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectSucBlock) {
            self.connectSucBlock(sock.connectedHost, sock.connectedPort);
        }
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    if (!err) {
        return;
    }
    self.connectTimeout = NO;
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    [self.operationQueue cancelAllOperations];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.connectFailedBlock) {
            self.connectFailedBlock([MKSocketBlockAdopter exchangedGCDAsyncSocketErrorToLocalError:err]);
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //发送成功之后读取数值
    NSLog(@"发送数据成功");
    [self.socket readDataWithTimeout:defaultCommandTime tag:tag];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKSocketTaskOperation *operation in operations) {
            if (operation.executing) {
                [operation sendDataToPlugSuccess:NO operationID:tag returnData:nil];
                break;
            }
        }
    }
    return 0.f;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"HTTP Response:\n%@", httpResponse);
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKSocketTaskOperation *operation in operations) {
            if (operation.executing) {
                [operation sendDataToPlugSuccess:YES
                                     operationID:tag
                                      returnData:[MKSocketAdopter dictionaryWithJsonString:httpResponse]];
                break;
            }
        }
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKSocketTaskOperation *operation in operations) {
            if (operation.executing) {
                [operation sendDataToPlugSuccess:NO operationID:tag returnData:nil];
                break;
            }
        }
    }
    return 0.f;
}

#pragma mark - public method

/**
 连接plug设备

 @param host host ip address
 @param port port (0~65535)
 @param sucBlock 连接成功回调
 @param failedBlock 连接失败回调
 */
- (void)connectDeviceWithHost:(NSString *)host
                         port:(NSInteger)port
              connectSucBlock:(void (^)(NSString *IP, NSInteger port))sucBlock
           connectFailedBlock:(void (^)(NSError *error))failedBlock{
    if (![MKSocketAdopter isValidatIP:host] || port < 0 || port > 65535) {
        [MKSocketBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [self connectHost:host port:port sucBlock:^(NSString *IP, NSInteger port) {
        if (sucBlock) {
            sucBlock(IP,port);
        }
        __strong typeof(self) sself = weakSelf;
        [sself clearConnectBlock];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        __strong typeof(self) sself = weakSelf;
        [sself clearConnectBlock];
    }];
}

/**
 断开连接
 */
- (void)disconnect{
    [self.socket disconnect];
}

#pragma mark - interface
/**
 读取设备信息

 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)readSmartPlugDeviceInformationWithSucBlock:(void (^)(id returnData))sucBlock
                                       failedBlock:(void (^)(NSError *error))failedBlock{
    NSString *jsonString = [MKSocketAdopter convertToJsonData:@{@"header":@(4001)}];
    [self addTaskWithTaskID:socketReadDeviceInformationOperation
                 jsonString:jsonString
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

- (void)configMQTTServerHost:(NSString *)host
                        port:(NSInteger)port
                 connectMode:(mqttServerConnectMode)mode
                         qos:(mqttServerQosMode)qos
                   keepalive:(NSInteger)keepalive
                cleanSession:(BOOL)clean
                    clientId:(NSString *)clientId
                    username:(NSString *)username
                    password:(NSString *)password
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    if (![MKSocketAdopter isValidatIP:host] && (host.length < 1 || host.length > 63)) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Host error" block:failedBlock];
        return;
    }
    if (port < 0 || port > 65535) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Port effective range : 0~65535" block:failedBlock];
        return;
    }
    if (keepalive < 10 || keepalive > 120) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Keep alive effective range : 10~120" block:failedBlock];
        return;
    }
    if (clientId && clientId.length > 64) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Client id error" block:failedBlock];
        return;
    }
    if (username.length > 256) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"User name error" block:failedBlock];
        return;
    }
    if (password.length > 256) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Password error" block:failedBlock];
        return;
    }
    NSInteger qosNumber = 2;
    if (qos == mqttQosLevelAtMostOnce) {
        qosNumber = 0;
    }else if (qos == mqttQosLevelAtLeastOnce){
        qosNumber = 1;
    }
    NSInteger connectModel = 0;
    if (mode == mqttServerConnectOneWaySSLMode) {
        connectModel = 1;
    }else if (mode == mqttServerConnectTwoWaySSLMode) {
        connectModel = 3;
    }
    NSDictionary *commandDic = @{
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
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigMQTTServerOperation
                 jsonString:jsonString
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

- (void)configCACertificate:(NSData *)certificate
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (!certificate || ![certificate isKindOfClass:NSData.class]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Certificate cann't be empty." block:failedBlock];
        return;
    }
    [self sendCertDataToDevice:certificate type:1 sucBlock:sucBlock failedBlock:failedBlock];
}

- (void)configClientCertificate:(NSData *)certificate
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (!certificate || ![certificate isKindOfClass:NSData.class]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Certificate cann't be empty." block:failedBlock];
        return;
    }
    [self sendCertDataToDevice:certificate type:2 sucBlock:sucBlock failedBlock:failedBlock];
}

- (void)configClientKey:(NSData *)clientKey
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    if (!clientKey || ![clientKey isKindOfClass:NSData.class]) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Client key cann't be empty." block:failedBlock];
        return;
    }
    [self sendCertDataToDevice:clientKey type:3 sucBlock:sucBlock failedBlock:failedBlock];
}

- (void)configDeviceMQTTTopic:(NSString *)subscibeTopic
                 publishTopic:(NSString *)publishTopic
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock {
    if (!subscibeTopic || subscibeTopic.length < 1 || subscibeTopic.length > 128) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Subscibe topic error" block:failedBlock];
        return;
    }
    if (!publishTopic || publishTopic.length < 1 || publishTopic.length > 128) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"Publish topic error" block:failedBlock];
        return;
    }
    NSDictionary *commandDic = @{
                                 @"header":@(4004),
                                 @"set_publish_topic":publishTopic,
                                 @"set_subscibe_topic":(subscibeTopic),
                                 };
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigTopicOperation
                 jsonString:jsonString
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

- (void)configEquipmentElectricalDefaultState:(mk_electricalDefaultState)state
                                     sucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock {
    NSDictionary *commandDic = @{
                                 @"header":@(4005),
                                 @"switch_status":@(state),
                                 };
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigEquipmentElectricalDefaultStateOperation
                 jsonString:jsonString
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

/**
 手机给插座指定连接特定ssid的WiFi网络。注意:调用该方法的时候，应该确保已经把mqtt服务器信息设置给plug了，否则调用该方法会出现错误

 @param ssid wifi ssid
 @param password wifi密码,不需要密码的wifi网络，密码可以不填
 @param security wifi加密策略
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configWifiSSID:(NSString *)ssid
              password:(NSString *)password
              security:(wifiSecurity)security
              sucBlock:(void (^)(id returnData))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock{
    if (!ssid || ssid.length == 0) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"SSID error" block:failedBlock];
        return;
    }
    NSInteger wifi_security = 0;
    if (security == wifiSecurity_WEP) {
        wifi_security = 1;
    }else if (security == wifiSecurity_WPA_PSK){
        wifi_security = 2;
    }else if (security == wifiSecurity_WPA2_PSK){
        wifi_security = 3;
    }else if (security == wifiSecurity_WPA_WPA2_PSK){
        wifi_security = 4;
    }
    NSDictionary *commandDic = @{
                                 @"header":@(4006),
                                 @"wifi_ssid":ssid,
                                 @"wifi_pwd":((!password || password.length == 0) ? @"" : password),
                                 @"wifi_security":@(wifi_security),
                                 };
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigWifiOperation
                 jsonString:jsonString
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

- (void)configMQTTID:(NSString *)mqttID
            sucBlock:(void (^)(id returnData))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock {
    if (!mqttID || ![mqttID isKindOfClass:NSString.class] || mqttID.length < 1 || mqttID.length > 32) {
        [MKSocketBlockAdopter operationParamsErrorWithMessage:@"MQTTID error" block:failedBlock];
        return;
    }
    NSDictionary *commandDic = @{
                                 @"header":@(4007),
                                 @"id":mqttID,
                                 };
    NSString *jsonString = [MKSocketAdopter convertToJsonData:commandDic];
    [self addTaskWithTaskID:socketConfigDeviceMQTTIDOperation
                 jsonString:jsonString
                   sucBlock:sucBlock
                failedBlock:failedBlock];
}

#pragma mark - connect private method
- (void)connectHost:(NSString *)host
               port:(NSInteger)port
           sucBlock:(void (^)(NSString *IP, NSInteger port))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock{
    self.connectSucBlock = nil;
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = nil;
    self.connectFailedBlock = failedBlock;
    if (self.socket.isConnected) {
        [self.socket disconnect];
    }
    self.connectTimeout = NO;
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    [self initConnectTimer];
    NSError *error = nil;
    BOOL pass = [self.socket connectToHost:host onPort:port withTimeout:defaultConnectTime error:&error];
    if (!pass) {
        [self.operationQueue cancelAllOperations];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failedBlock) {
                failedBlock(error);
            }
        });
    }
}

- (void)addTaskWithTaskID:(MKSocketOperationID)taskID
               jsonString:(NSString *)jsonString
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock{
    if (!jsonString) {
        [MKSocketBlockAdopter operationGetDataErrorBlock:failedBlock];
        return;
    }
    if (!self.socket.isConnected) {
        [MKSocketBlockAdopter operationDisConnectedErrorBlock:failedBlock];
        return;
    }
    MKSocketTaskOperation *operation = [[MKSocketTaskOperation alloc] initOperationWithID:taskID completeBlock:^(NSError *error, MKSocketOperationID operationID, id returnData) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedBlock) {
                    failedBlock(error);
                }
            });
            return ;
        }
        if (!returnData || ![returnData isKindOfClass:[NSDictionary class]]) {
            //出错
            [MKSocketBlockAdopter operationGetDataErrorBlock:failedBlock];
        }
        if ([returnData[@"code"] integerValue] != 0) {
            //数据错误
            [MKSocketBlockAdopter operationDataErrorWithReturnData:returnData block:failedBlock];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock(returnData);
            }
        });
    }];
    [self.operationQueue addOperation:operation];
    NSData *commandData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:commandData withTimeout:defaultCommandTime tag:taskID];
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailedBlock) {
        self.connectFailedBlock = nil;
    }
}

- (void)initConnectTimer{
    dispatch_queue_t connectQueue = dispatch_queue_create("connectSmartPlugQueue", DISPATCH_QUEUE_CONCURRENT);
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,connectQueue);
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, defaultConnectTime * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = defaultConnectTime * NSEC_PER_SEC;
    dispatch_source_set_timer(self.connectTimer, start, interval, 0);
    __weak __typeof(&*self)weakSelf = self;
    dispatch_source_set_event_handler(self.connectTimer, ^{
        __strong typeof(self) sself = weakSelf;
        sself.connectTimeout = YES;
        dispatch_cancel(sself.connectTimer);
        [sself.socket disconnect];
        [MKSocketBlockAdopter operationConnectTimeoutBlock:sself.connectFailedBlock];
    });
    dispatch_resume(self.connectTimer);
}

#pragma mark - cert
- (void)sendCertDataToDevice:(NSData *)certData
                        type:(NSInteger)type
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    if (!certData || certData.length == 0) {
        [MKSocketBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
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
            NSString *subData = tempData.utf8String;
            if (!subData || ![subData isKindOfClass:NSString.class]) {
                [MKSocketBlockAdopter operationParamsErrorBlock:failedBlock];
                return;
            }
            NSDictionary *dataDic = @{
                                      @"header":@(4003),
                                      @"file_type":@(type),
                                      @"file_size":@(certData.length),
                                      @"current_packet_len":@(subData.length),
                                      @"data":subData,
                                      @"offset":@(i * certPackageDataLength),
                                      };
            NSString *jsonString = [MKSocketAdopter convertToJsonData:dataDic];
            NSLog(@"+++++++++++++++++%@",dataDic);
            NSError *error = [self sendCertDataSuccess:jsonString];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (failedBlock) {
                        failedBlock(error);
                    }
                });
                return ;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sucBlock) {
                sucBlock();
            }
        });
    });
}

- (NSError *)sendCertDataSuccess:(NSString *)jsonString {
    __block NSError *sendError = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self addTaskWithTaskID:socketConfigDeviceCertOperation jsonString:jsonString sucBlock:^(id returnData) {
        dispatch_semaphore_signal(semaphore);
    } failedBlock:^(NSError *error) {
        sendError = error;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return sendError;
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

- (dispatch_queue_t)certQueue {
    if (!_certQueue) {
        _certQueue = dispatch_queue_create("com.moko.socketCertQueue", 0);
    }
    return _certQueue;
}

@end
