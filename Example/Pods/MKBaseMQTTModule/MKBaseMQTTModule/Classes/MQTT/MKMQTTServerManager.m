//
//  MKMQTTServerManager.m
//  MKBaseMQTTModule_Example
//
//  Created by aa on 2021/8/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKMQTTServerManager.h"

#import "MKMQTTServerSDKDefines.h"

#import "MKMQTTServerSDKAdopter.h"

NSString *const MKMQTTServerManagerDidChangeStateNotification = @"MKMQTTServerManagerDidChangeStateNotification";

static MKMQTTServerManager *manager = nil;
static dispatch_once_t onceToken;

@interface NSObject (MKMQTTServerManager)

@end

@implementation NSObject (MKMQTTServerManager)

+ (void)load{
    [MKMQTTServerManager shared];
}

@end

@interface MKMQTTServerManager ()<MQTTSessionManagerDelegate>

@property (nonatomic, strong)MQTTSessionManager *sessionManager;

@property (nonatomic, assign)MKMQTTSessionManagerState managerState;

@property (nonatomic, strong)NSMutableDictionary *subscriptions;

@property (nonatomic, strong)NSMutableArray <id <MKMQTTServerProtocol>>*managerList;

@end

@implementation MKMQTTServerManager

+ (MKMQTTServerManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKMQTTServerManager new];
        }
    });
    return manager;
}

+ (void)singleDealloc {
    onceToken = 0;
    manager = nil;
}

#pragma mark - MQTTSessionManagerDelegate
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    @synchronized (self.managerList) {
        for (id <MKMQTTServerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(handleMessage:onTopic:retained:)]) {
                [protocol handleMessage:data onTopic:topic retained:retained];
            }
        }
    }
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained {
    @synchronized (self.managerList) {
        for (id <MKMQTTServerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(sessionManager:didReceiveMessage:onTopic:retained:)]) {
                [protocol sessionManager:sessionManager didReceiveMessage:data onTopic:topic retained:retained];
            }
        }
    }
}

- (void)messageDelivered:(UInt16)msgID {
    @synchronized (self.managerList) {
        for (id <MKMQTTServerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(messageDelivered:)]) {
                [protocol messageDelivered:msgID];
            }
        }
    }
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID {
    @synchronized (self.managerList) {
        for (id <MKMQTTServerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(sessionManager:didDeliverMessage:)]) {
                [protocol sessionManager:sessionManager didDeliverMessage:msgID];
            }
        }
    }
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    self.managerState = [self fecthSessionState:newState];
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTServerManagerDidChangeStateNotification
                                                        object:nil
                                                      userInfo:nil];
    @synchronized (self.managerList) {
        for (id <MKMQTTServerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(sessionManager:didChangeState:)]) {
                [protocol sessionManager:sessionManager didChangeState:self.managerState];
            }
        }
    }
    if (self.managerState == MKMQTTSessionManagerStateConnected) {
        //连接成功了，订阅主题
        self.sessionManager.subscriptions = [NSDictionary dictionaryWithDictionary:self.subscriptions];
    }
    if (self.managerState == MKMQTTSessionManagerStateError) {
        //连接出错
        [self disconnect];
    }
}


#pragma mark - public method
- (void)loadDataManager:(nonnull id <MKMQTTServerProtocol>)dataManager {
    @synchronized (self.managerList) {
        if (dataManager
            && [dataManager conformsToProtocol:@protocol(MKMQTTServerProtocol)]
            && ![self.managerList containsObject:dataManager]) {
            [self.managerList addObject:dataManager];
        }
    }
}

- (BOOL)removeDataManager:(nonnull id <MKMQTTServerProtocol>)dataManager {
    @synchronized (self.managerList) {
        if (!dataManager ||
            ![dataManager conformsToProtocol:@protocol(MKMQTTServerProtocol)] ||
            ![self.managerList containsObject:dataManager]) {
            return NO;
        }
        [self.managerList removeObject:dataManager];
        return YES;
    }
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(MQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates
    protocolLevel:(MQTTProtocolVersion)protocolLevel
   connectHandler:(MQTTConnectHandler)connectHandler {
    if (self.sessionManager) {
        self.sessionManager.delegate = nil;
        [self.sessionManager disconnectWithDisconnectHandler:nil];
        self.sessionManager = nil;
    }
    MQTTSessionManager *sessionManager = [[MQTTSessionManager alloc] init];
    sessionManager.delegate = self;
    self.sessionManager = sessionManager;
    [self.sessionManager connectTo:host
                              port:port
                               tls:tls
                         keepalive:keepalive
                             clean:clean
                              auth:auth
                              user:user
                              pass:pass
                              will:will
                         willTopic:willTopic
                           willMsg:willMsg
                           willQos:willQos
                    willRetainFlag:willRetainFlag
                      withClientId:clientId
                    securityPolicy:securityPolicy
                      certificates:certificates
                     protocolLevel:protocolLevel
                    connectHandler:connectHandler];
}

- (void)disconnect {
    if (!self.sessionManager) {
        return;
    }
    self.sessionManager.delegate = nil;
    [self.sessionManager disconnectWithDisconnectHandler:nil];
    self.sessionManager = nil;
    self.managerState = MQTTSessionManagerStateStarting;
}

- (void)subscriptions:(NSArray <NSString *>*)topicList qosLevel:(MQTTQosLevel)qosLevel {
    if (!MKMQTTValidArray(topicList)) {
        return;
    }
    @synchronized(self){
        for (NSString *topic in topicList) {
            if (MKMQTTValidStr(topic)) {
                [self.subscriptions setObject:@(qosLevel) forKey:topic];
            }
        }
        if (self.sessionManager && self.managerState == MQTTSessionManagerStateConnected) {
            //连接成功了，订阅主题
            self.sessionManager.subscriptions = [NSDictionary dictionaryWithDictionary:self.subscriptions];
        }
    }
}

- (void)unsubscriptions:(NSArray <NSString *>*)topicList {
    if (!self.sessionManager
        || !MKMQTTValidArray(topicList)) {
        return;
    }
    @synchronized(self){
        NSMutableArray *removeTopicList = [NSMutableArray array];
        for (NSString *topic in topicList) {
            if (MKMQTTValidStr(topic)) {
                NSString *value = self.subscriptions[topic];
                if (value) {
                    [self.subscriptions removeObjectForKey:topic];
                    [removeTopicList addObject:topic];
                }
            }
        }
        if (removeTopicList.count == 0) {
            return;
        }
        self.sessionManager.subscriptions = [NSDictionary dictionaryWithDictionary:self.subscriptions];
        [self.sessionManager.session unsubscribeTopics:removeTopicList];
    }
}

- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        qosLevel:(MQTTQosLevel)qosLevel
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKMQTTValidDict(data)) {
        [self operationFailedBlockWithMsg:@"Params error" block:failedBlock];
        return;
    }
    if (!MKMQTTValidStr(topic)) {
        [self operationFailedBlockWithMsg:@"Topic error" block:failedBlock];
        return;
    }
    if (!self.sessionManager) {
        [self operationFailedBlockWithMsg:@"MTQQ Server disconnect" block:failedBlock];
        return;
    }
    UInt16 msgid = [self.sessionManager sendData:[MKMQTTServerSDKAdopter parseJsonToData:data] //要发送的消息体
                                           topic:topic //要往哪个topic发送消息
                                             qos:qosLevel //消息级别
                                          retain:false];
    if (msgid <= 0) {
        [self operationFailedBlockWithMsg:@"Send data error" block:failedBlock];
        return;
    }
    MKMQTTBase_main_safe(^{
        if (sucBlock) {
            sucBlock();
        }
    });
}

- (void)publishData:(NSData *)data
              topic:(NSString *)topic
           qosLevel:(MQTTQosLevel)qosLevel
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKMQTTValidData(data)) {
        [self operationFailedBlockWithMsg:@"Params error" block:failedBlock];
        return;
    }
    if (!MKMQTTValidStr(topic)) {
        [self operationFailedBlockWithMsg:@"Topic error" block:failedBlock];
        return;
    }
    if (!self.sessionManager) {
        [self operationFailedBlockWithMsg:@"MTQQ Server disconnect" block:failedBlock];
        return;
    }
    UInt16 msgid = [self.sessionManager sendData:data   //要发送的消息体
                                           topic:topic //要往哪个topic发送消息
                                             qos:qosLevel //消息级别
                                          retain:false];
    if (msgid <= 0) {
        [self operationFailedBlockWithMsg:@"Send data error" block:failedBlock];
        return;
    }
    MKMQTTBase_main_safe(^{
        if (sucBlock) {
            sucBlock();
        }
    });
}


#pragma mark - private method
- (MKMQTTSessionManagerState)fecthSessionState:(MQTTSessionManagerState)orignState {
    switch (orignState) {
        case MQTTSessionManagerStateError:
            return MKMQTTSessionManagerStateError;
        case MQTTSessionManagerStateClosed:
            return MKMQTTSessionManagerStateClosed;
        case MQTTSessionManagerStateClosing:
            return MKMQTTSessionManagerStateClosing;
        case MQTTSessionManagerStateStarting:
            return MKMQTTSessionManagerStateStarting;
        case MQTTSessionManagerStateConnected:
            return MKMQTTSessionManagerStateConnected;
        case MQTTSessionManagerStateConnecting:
            return MKMQTTSessionManagerStateConnecting;
    }
}

- (void)operationFailedBlockWithMsg:(NSString *)msg block:(void (^)(NSError *error))block {
    MKMQTTBase_main_safe(^{
        if (block) {
            NSError *error = [[NSError alloc] initWithDomain:@"com.moko.MKMQTTServerSDK"
                                                        code:-999
                                                    userInfo:@{@"errorInfo":msg}];
            block(error);
        }
    })
}

#pragma mark - getter
- (NSMutableDictionary *)subscriptions {
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    return _subscriptions;
}

- (NSMutableArray<id<MKMQTTServerProtocol>> *)managerList {
    if (!_managerList) {
        _managerList = [NSMutableArray array];
    }
    return _managerList;
}

@end
