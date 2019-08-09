//
//  MKSmartPlugConnectManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKSmartPlugConnectManager.h"
#import "MKConfigServerModel.h"
#import "MKSocketManager.h"

@interface MKSmartPlugConnectManager()

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSMutableDictionary *paramDic;

@property (nonatomic, strong)MKConfigServerModel *configServerModel;

@property (nonatomic, copy)NSString *wifi_ssid;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, strong)NSMutableDictionary *deviceInfoDic;

@property (nonatomic, copy)void (^connectSucBlock)(NSDictionary *deviceInfo);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

@end

@implementation MKSmartPlugConnectManager

#pragma mark - life circle
- (void)configDeviceWithWifiSSID:(NSString *)wifi_ssid
                        password:(NSString *)password
                     serverModel:(MKConfigServerModel *)serverModel
                        sucBlock:(void (^)(NSDictionary *deviceInfo))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock{
    self.wifi_ssid = wifi_ssid;
    self.password = password;
    WS(weakSelf);
    [self.configServerModel updateServerDataWithModel:serverModel];
    [self connectPlugWithSucBlock:^(NSDictionary *deviceInfo) {
        if (sucBlock) {
            sucBlock(deviceInfo);
        }
        weakSelf.connectFailedBlock = nil;
        weakSelf.connectSucBlock = nil;
        weakSelf.deviceInfoDic = nil;
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        weakSelf.connectFailedBlock = nil;
        weakSelf.connectSucBlock = nil;
        weakSelf.deviceInfoDic = nil;
    }];
}

#pragma mark - private method
- (void)connectPlugWithSucBlock:(void (^)(NSDictionary *deviceInfo))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock{
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = failedBlock;
    self.deviceInfoDic = nil;
    WS(weakSelf);
    [[MKSocketManager sharedInstance] connectDeviceWithHost:defaultHostIpAddress port:defaultPort connectSucBlock:^(NSString *IP, NSInteger port) {
        [weakSelf readDeviceInfo];
    } connectFailedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)readDeviceInfo{
    WS(weakSelf);
    [[MKSocketManager sharedInstance] readSmartPlugDeviceInformationWithSucBlock:^(id returnData) {
        weakSelf.deviceInfoDic = [NSMutableDictionary dictionaryWithDictionary:returnData[@"result"]];
        [weakSelf configMqttServer];
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configMqttServer{
    WS(weakSelf);
    mqttServerQosMode qoeMode = mqttQosLevelExactlyOnce;
    if ([self.configServerModel.qos isEqualToString:@"0"]) {
        //
        qoeMode = mqttQosLevelAtMostOnce;
    }else if ([self.configServerModel.qos isEqualToString:@"1"]){
        qoeMode = mqttQosLevelAtLeastOnce;
    }
    [[MKSocketManager sharedInstance] configMQTTServerHost:self.configServerModel.host
                                                      port:[self.configServerModel.port integerValue]
                                               connectMode:self.configServerModel.connectMode
                                                       qos:qoeMode
                                                 keepalive:[self.configServerModel.keepAlive integerValue]
                                              cleanSession:self.configServerModel.cleanSession clientId:self.configServerModel.clientId username:self.configServerModel.userName password:self.configServerModel.password
                                                  sucBlock:^(id returnData) {
        [weakSelf configCACerts];
    }
                                               failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configCACerts {
    if (self.configServerModel.connectMode == 0) {
        //tcp不需要证书
        [self configTopic];
        return;
    }
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.caFileName];
    NSData *caData = [NSData dataWithContentsOfFile:filePath];
    if (!ValidData(caData)) {
        [self configClientCert];
        return;
    }
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configCACertificate:caData sucBlock:^{
        [weakSelf configClientCert];
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configClientCert {
    if (self.configServerModel.connectMode == 1) {
        //单项验证只需要CA证书
        [self configTopic];
        return;
    }
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.clientCertName];
    NSData *caData = [NSData dataWithContentsOfFile:filePath];
    if (!ValidData(caData)) {
        [self configClientKey];
        return;
    }
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configClientCertificate:caData sucBlock:^{
        [weakSelf configClientKey];
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configClientKey {
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [document stringByAppendingPathComponent:self.configServerModel.clientKeyName];
    NSData *caData = [NSData dataWithContentsOfFile:filePath];
    if (!ValidData(caData)) {
        [self configTopic];
        return;
    }
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configClientKey:caData sucBlock:^{
        [weakSelf configTopic];
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configTopic {
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configDeviceMQTTTopic:self.configServerModel.subscribedTopic publishTopic:self.configServerModel.publishedTopic sucBlock:^(id returnData) {
        [weakSelf configWifiInfo];
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

- (void)configWifiInfo{
    WS(weakSelf);
    [[MKSocketManager sharedInstance] configWifiSSID:self.wifi_ssid password:self.password security:wifiSecurity_WPA2_PSK sucBlock:^(id returnData) {
        if (weakSelf.connectSucBlock) {
            weakSelf.connectSucBlock(weakSelf.deviceInfoDic);
        }
    } failedBlock:^(NSError *error) {
        if (weakSelf.connectFailedBlock) {
            weakSelf.connectFailedBlock(error);
        }
    }];
}

#pragma mark - setter & getter
- (MKConfigServerModel *)configServerModel{
    if (!_configServerModel) {
        _configServerModel = [[MKConfigServerModel alloc] init];
    }
    return _configServerModel;
}

@end
