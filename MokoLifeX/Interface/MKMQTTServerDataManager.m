//
//  MKMQTTServerDataManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerDataManager.h"
#import "MKConfigServerModel.h"
#import "MQTTSSLSecurityPolicy.h"
#import <MQTTClient/MQTTSessionManager.h>
#import <MQTTClient/MQTTSSLSecurityPolicyTransport.h>

NSString *const MKMQTTSessionManagerStateChangedNotification = @"MKMQTTSessionManagerStateChangedNotification";

NSString *const MKMQTTServerReceivedSwitchStateNotification = @"MKMQTTServerReceivedSwitchStateNotification";
NSString *const MKMQTTServerReceivedDelayTimeNotification = @"MKMQTTServerReceivedDelayTimeNotification";
NSString *const MKMQTTServerReceivedElectricityNotification = @"MKMQTTServerReceivedElectricityNotification";
NSString *const MKMQTTServerReceivedFirmwareInfoNotification = @"MKMQTTServerReceivedFirmwareInfoNotification";
NSString *const MKMQTTServerReceivedUpdateResultNotification = @"MKMQTTServerReceivedUpdateResultNotification";
NSString *const MKMQTTServerReceivedDevicePowerOnStatusNotification = @"MKMQTTServerReceivedDevicePowerOnStatusNotification";
NSString *const MKMQTTServerReceivedOverloadNotification = @"MKMQTTServerReceivedOverloadNotification";
NSString *const MKMQTTServerReceivedPowerReportPeriodNotification = @"MKMQTTServerReceivedPowerReportPeriodNotification";
NSString *const MKMQTTServerReceivedEnergyReportPeriodNotification = @"MKMQTTServerReceivedEnergyReportPeriodNotification";
NSString *const MKMQTTServerReceivedStorageParametersNotification = @"MKMQTTServerReceivedStorageParametersNotification";
NSString *const MKMQTTServerReceivedLEDColorNotification = @"MKMQTTServerReceivedLEDColorNotification";
NSString *const MKMQTTServerReceivedHistoricalEnergyNotification = @"MKMQTTServerReceivedHistoricalEnergyNotification";
NSString *const MKMQTTServerReceivedEnergyDataOfTodayNotification = @"MKMQTTServerReceivedEnergyDataOfTodayNotification";
NSString *const MKMQTTServerReceivedPulseConstantNotification = @"MKMQTTServerReceivedPulseConstantNotification";
NSString *const MKMQTTServerReceivedTotalEnergyNotification = @"MKMQTTServerReceivedTotalEnergyNotification";
NSString *const MKMQTTServerReceivedCurrentEnergyNotification = @"MKMQTTServerReceivedCurrentEnergyNotification";

@interface MKMQTTServerDataManager()<MKMQTTServerManagerDelegate>

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSMutableDictionary *paramDic;

@property (nonatomic, strong)MKConfigServerModel *configServerModel;

@property (nonatomic, assign)MKMQTTSessionManagerState state;

@end

@implementation MKMQTTServerDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (instancetype)init{
    if (self = [super init]) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.filePath = [documentPath stringByAppendingPathComponent:@"MQTTServerConfigForApp.txt"];
        self.paramDic = [[NSMutableDictionary alloc] initWithContentsOfFile:self.filePath];
        if (!self.paramDic){
            self.paramDic = [NSMutableDictionary dictionary];
        }
        [self.configServerModel updateServerModelWithDic:self.paramDic];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkStateChanged)
                                           name:UIApplicationDidBecomeActiveNotification
                                         object:nil];
        [MKMQTTServerManager sharedInstance].delegate = self;
    }
    return self;
}

+ (MKMQTTServerDataManager *)sharedInstance{
    static MKMQTTServerDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKMQTTServerDataManager new];
        }
    });
    return manager;
}

#pragma mark - MKMQTTServerManagerDelegate
- (void)mqttServerManagerStateChanged:(MKMQTTSessionManagerState)state{
    self.state = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:MKMQTTSessionManagerStateChangedNotification object:nil];
}

- (void)sessionManager:(MKMQTTServerManager *)sessionManager didReceiveMessage:(NSData *)data onTopic:(NSString *)topic{
    if (!topic) {
        return;
    }
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * datas = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingAllowFragments error:nil];
    if (!ValidDict(dataDic)) {
        return;
    }
    if (!ValidStr(dataDic[@"id"]) || !ValidNum(dataDic[@"msg_id"])) {
        return;
    }
    NSLog(@"接收到数据:%@",dataDic);
    NSNumber *function = dataDic[@"msg_id"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dataDic[@"data"]];
    [tempDic setObject:topic forKey:@"deviceTopic"];
    [tempDic setObject:function forKey:@"function"];
    [tempDic setObject:dataDic[@"id"] forKey:@"id"];
    NSLog(@"接收到数据:%@",tempDic);
    NSString *notificationName = [self fetchNotificationNameWithFunction:[function integerValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:nil
                                                      userInfo:@{@"userInfo" : tempDic}];
}

#pragma mark - event method
- (void)networkStateChanged{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]
        || [MKDeviceModel currentWifiIsCorrect:MKDevice_swich]
        || [MKDeviceModel currentWifiIsCorrect:MKDevice_plug]) {
        //如果是当前网络不可用或者是连接的plug设备，则断开当前手机与mqtt服务器的连接操作
        [[MKMQTTServerManager sharedInstance] disconnect];
        return;
    }
    if ([MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnected
        || [MKMQTTServerManager sharedInstance].managerState == MKMQTTSessionManagerStateConnecting) {
        //已经连接或者正在连接，直接返回
        return;
    }
    //如果网络可用，则连接
    [self connectServer];
}

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model{
    if (!model) {
        return;
    }
    [self.configServerModel updateServerDataWithModel:model];
    [self synchronize];
}

/**
 记录到本地
 */
- (void)synchronize{
    [self.paramDic setObject:SafeStr(self.configServerModel.host) forKey:@"host"];
    [self.paramDic setObject:SafeStr(self.configServerModel.port) forKey:@"port"];
    [self.paramDic setObject:@(self.configServerModel.cleanSession) forKey:@"cleanSession"];
    [self.paramDic setObject:@(self.configServerModel.connectMode) forKey:@"connectMode"];
    [self.paramDic setObject:SafeStr(self.configServerModel.qos) forKey:@"qos"];
    [self.paramDic setObject:SafeStr(self.configServerModel.keepAlive) forKey:@"keepAlive"];
    [self.paramDic setObject:SafeStr(self.configServerModel.clientId) forKey:@"clientId"];
    [self.paramDic setObject:SafeStr(self.configServerModel.userName) forKey:@"userName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.password) forKey:@"password"];
    [self.paramDic setObject:SafeStr(self.configServerModel.caFileName) forKey:@"caFileName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.clientP12CertName) forKey:@"clientP12CertName"];
    [self.paramDic setObject:SafeStr(self.configServerModel.publishedTopic) forKey:@"publishedTopic"];
    [self.paramDic setObject:SafeStr(self.configServerModel.subscribedTopic) forKey:@"subscribedTopic"];
    
    [self.paramDic writeToFile:self.filePath atomically:NO];
};

/**
 连接mqtt server
 
 */
- (void)connectServer{
    if (![self.configServerModel needParametersHasValue]) {
        //参数没有配置好，直接返回
        return;
    }
    MQTTSSLSecurityPolicy *securityPolicy = nil;
    NSArray *certList = nil;
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    if (self.configServerModel.connectMode != 0) {
        //需要tls
        if (ValidStr(self.configServerModel.caFileName)) {
            NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.caFileName];
            NSData *clientCert = [NSData dataWithContentsOfFile:filePath];
            if (ValidData(clientCert)) {
                securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeCertificate];
                securityPolicy.pinnedCertificates = @[clientCert];
            }else {
                securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
            }
            securityPolicy.allowInvalidCertificates = YES;
            securityPolicy.validatesDomainName = NO;
            securityPolicy.validatesCertificateChain = NO;
        }
    }
    if (self.configServerModel.connectMode == 2) {
        //双向验证
        NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.clientP12CertName];
        certList = [MQTTSSLSecurityPolicyTransport clientCertsFromP12:filePath passphrase:@"123456"];
    }
    [[MKMQTTServerManager sharedInstance] connectMQTTServer:self.configServerModel.host
                                                       port:[self.configServerModel.port integerValue]
                                                        tls:(self.configServerModel.connectMode != 0)
                                                  keepalive:[self.configServerModel.keepAlive integerValue]
                                                      clean:self.configServerModel.cleanSession
                                                       auth:YES
                                                       user:self.configServerModel.userName
                                                       pass:self.configServerModel.password
                                                   clientId:self.configServerModel.clientId
                                             securityPolicy:securityPolicy
                                               certificates:certList];
}

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData{
    MKConfigServerModel *model = [[MKConfigServerModel alloc] init];
    [self.configServerModel updateServerDataWithModel:model];
    [self synchronize];
}

#pragma mark - private method
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)fetchNotificationNameWithFunction:(NSInteger)function {
    if (function == 1001) {
        //开关状态
        return MKMQTTServerReceivedSwitchStateNotification;
    }
    if (function == 1002) {
        //固件信息
        return MKMQTTServerReceivedFirmwareInfoNotification;
    }
    if (function == 1003) {
        //倒计时
        return MKMQTTServerReceivedDelayTimeNotification;
    }
    if (function == 1004) {
        //固件升级结果
        return MKMQTTServerReceivedUpdateResultNotification;
    }
    if (function == 1005) {
        //载保护状态以及过载值
        return MKMQTTServerReceivedOverloadNotification;
    }
    if (function == 1006) {
        //电量信息
        return MKMQTTServerReceivedElectricityNotification;
    }
    if (function == 1008) {
        //读取插座上电默认开关状态
        return MKMQTTServerReceivedDevicePowerOnStatusNotification;
    }
    if (function == 1009) {
        //功率指示灯颜色
        return MKMQTTServerReceivedLEDColorNotification;
    }
    if (function == 1012) {
        //电量信息上报间隔
        return MKMQTTServerReceivedPowerReportPeriodNotification;
    }
    if (function == 1013) {
        //累计电能存储参数
        return MKMQTTServerReceivedStorageParametersNotification;
    }
    if (function == 1014) {
        //累计电能
        return MKMQTTServerReceivedHistoricalEnergyNotification;
    }
    if (function == 1015) {
        //今天电能
        return MKMQTTServerReceivedEnergyDataOfTodayNotification;
    }
    if (function == 1016) {
        //脉冲常数
        return MKMQTTServerReceivedPulseConstantNotification;
    }
    if (function == 1017) {
        //总累计电能
        return MKMQTTServerReceivedTotalEnergyNotification;
    }
    if (function == 1018) {
        //当前电能数据
        return MKMQTTServerReceivedCurrentEnergyNotification;
    }
    if (function == 1019) {
        //电能上报间隔
        return MKMQTTServerReceivedEnergyReportPeriodNotification;
    }
    return @"";
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end
