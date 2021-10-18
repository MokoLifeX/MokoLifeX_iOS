//
//  MKLFXServerManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXServerManager.h"

#import "MQTTSSLSecurityPolicyTransport.h"
#import "MQTTSSLSecurityPolicy.h"

#import "MKMQTTServerSDKDefines.h"

#import "MKNetworkManager.h"

#import "MKLFXServerParamsModel.h"

NSString *const MKLFXMQTTSessionManagerStateChangedNotification = @"MKLFXMQTTSessionManagerStateChangedNotification";

static MKLFXServerManager *manager = nil;
static dispatch_once_t onceToken;


@interface NSObject (MKLFXServerManager)

@end

@implementation NSObject (MKLFXServerManager)

+ (void)load{
    [MKLFXServerManager shared];
}

@end

@interface MKLFXServerManager ()

@property (nonatomic, assign)MKLFXMQTTSessionManagerState state;

@property (nonatomic, strong)MKLFXServerParamsModel *paramsModel;

@property (nonatomic, strong)NSMutableArray <id <MKLFXServerManagerProtocol>>*managerList;

@end

@implementation MKLFXServerManager

- (void)dealloc{
    NSLog(@"销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)init{
    if (self = [super init]) {
        [[MKMQTTServerManager shared] loadDataManager:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:UIApplicationDidBecomeActiveNotification
                                         object:nil];
    }
    return self;
}

+ (MKLFXServerManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXServerManager new];
        }
    });
    return manager;
}

+ (void)singleDealloc {
    [[MKMQTTServerManager shared] removeDataManager:self];
    onceToken = 0;
    manager = nil;
}

#pragma mark - MKMQTTServerProtocol

- (void)sessionManager:(MQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained {
    if (!MKMQTTValidStr(topic) || !MKMQTTValidData(data)) {
        return;
    }
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if (!MKMQTTValidDict(dataDic) || !MKMQTTValidStr(dataDic[@"id"])) {
        return;
    }
    @synchronized (self.managerList) {
        for (id <MKLFXServerManagerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(lfx_didReceiveMessage:onTopic:)]) {
                [protocol lfx_didReceiveMessage:dataDic onTopic:topic];
            }
        }
    }
}

- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MKMQTTSessionManagerState)newState {
    self.state = newState;
    [[NSNotificationCenter defaultCenter] postNotificationName:MKLFXMQTTSessionManagerStateChangedNotification object:nil];
    @synchronized (self.managerList) {
        for (id <MKLFXServerManagerProtocol>protocol in self.managerList) {
            if ([protocol respondsToSelector:@selector(lfx_didChangeState:)]) {
                [protocol lfx_didChangeState:self.state];
            }
        }
    }
}

#pragma mark - note
- (void)networkStateChanged{
    if (![self.paramsModel paramsCanConnectServer]) {
        //服务器连接参数缺失
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]) {
        //如果是当前网络不可用，则断开当前手机与mqtt服务器的连接操作
        [[MKMQTTServerManager shared] disconnect];
        self.state = MKLFXMQTTSessionManagerStateStarting;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKLFXMQTTSessionManagerStateChangedNotification object:nil];
        return;
    }
    if ([MKMQTTServerManager shared].managerState == MKMQTTSessionManagerStateConnected
        || [MKMQTTServerManager shared].managerState == MKMQTTSessionManagerStateConnecting) {
        //已经连接或者正在连接，直接返回
        return;
    }
    //如果网络可用，则连接
    [self connect];
}

#pragma mark - public method

- (BOOL)saveServerParams:(id <MKLFXServerParamsProtocol>)protocol {
    return [self.paramsModel saveServerParams:protocol];
}

- (BOOL)clearLocalData {
    return [self.paramsModel clearLocalData];
}

- (void)loadDataManager:(nonnull id <MKLFXServerManagerProtocol>)dataManager {
    @synchronized (self.managerList) {
        if (dataManager
            && [dataManager conformsToProtocol:@protocol(MKLFXServerManagerProtocol)]
            && ![self.managerList containsObject:dataManager]) {
            [self.managerList addObject:dataManager];
        }
    }
}

- (BOOL)removeDataManager:(nonnull id <MKLFXServerManagerProtocol>)dataManager {
    @synchronized (self.managerList) {
        if (!dataManager ||
            ![dataManager conformsToProtocol:@protocol(MKLFXServerManagerProtocol)] ||
            ![self.managerList containsObject:dataManager]) {
            return NO;
        }
        [self.managerList removeObject:dataManager];
        return YES;
    }
}

- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager shared] sendData:data
                                     topic:topic
                                  qosLevel:MQTTQosLevelAtLeastOnce
                                  sucBlock:sucBlock
                               failedBlock:failedBlock];
}

#pragma mark - *****************************服务器交互部分******************************

- (BOOL)connect {
    if (![self.paramsModel paramsCanConnectServer]) {
        return NO;
    }
    MQTTSSLSecurityPolicy *securityPolicy = nil;
    NSArray *certList = nil;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (self.paramsModel.sslIsOn) {
        //需要ssl验证
        if (self.paramsModel.certificate == 0) {
            //不需要CA根证书
            securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
        }
        if (self.paramsModel.certificate == 1 || self.paramsModel.certificate == 2) {
            //需要CA证书
            NSString *filePath = [document stringByAppendingPathComponent:self.paramsModel.caFileName];
            NSData *clientCert = [NSData dataWithContentsOfFile:filePath];
            if (MKMQTTValidData(clientCert)) {
                securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
                securityPolicy.pinnedCertificates = @[clientCert];
            }else {
                //未加载到CA证书
                securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
            }
        }
        if (self.paramsModel.certificate == 2) {
            //双向验证
            NSString *filePath = [document stringByAppendingPathComponent:self.paramsModel.clientFileName];
            certList = [MQTTSSLSecurityPolicyTransport clientCertsFromP12:filePath passphrase:@"123456"];
        }
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        securityPolicy.validatesCertificateChain = NO;
    }
    [[MKMQTTServerManager shared] connectTo:self.paramsModel.host
                                       port:[self.paramsModel.port integerValue]
                                        tls:self.paramsModel.sslIsOn
                                  keepalive:[self.paramsModel.keepAlive integerValue]
                                      clean:self.paramsModel.cleanSession
                                       auth:YES
                                       user:self.paramsModel.userName
                                       pass:self.paramsModel.password
                                       will:NO
                                  willTopic:nil
                                    willMsg:nil
                                    willQos:0
                             willRetainFlag:NO
                               withClientId:self.paramsModel.clientID
                             securityPolicy:securityPolicy
                               certificates:certList
                              protocolLevel:MQTTProtocolVersion311
                             connectHandler:nil];
    return YES;
}

- (BOOL)disconnect {
    [[MKMQTTServerManager shared] disconnect];
}

- (void)subscriptions:(NSArray <NSString *>*)topicList {
    [[MKMQTTServerManager shared] subscriptions:topicList qosLevel:MQTTQosLevelAtLeastOnce];
}

- (void)unsubscriptions:(NSArray <NSString *>*)topicList {
    [[MKMQTTServerManager shared] unsubscriptions:topicList];
}

- (id<MKLFXServerParamsProtocol>)currentServerParams {
    return self.paramsModel;
}

#pragma mark - getter
- (MKLFXServerParamsModel *)paramsModel {
    if (!_paramsModel) {
        _paramsModel = [[MKLFXServerParamsModel alloc] init];
    }
    return _paramsModel;
}

- (NSMutableArray<id<MKLFXServerManagerProtocol>> *)managerList {
    if (!_managerList) {
        _managerList = [NSMutableArray array];
    }
    return _managerList;
}

@end
