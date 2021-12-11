//
//  MKLFXServerParamsModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXServerParamsModel.h"

#import "MKMQTTServerSDKDefines.h"
#import "MKMQTTServerSDKAdopter.h"

static NSString *const fileName = @"MKLFXServerParams.txt";

@interface MKLFXServerParamsModel ()

@property (nonatomic, copy)NSString *filePath;

@property (nonatomic, strong)NSDictionary *serverParams;

@end

@implementation MKLFXServerParamsModel

- (instancetype)init {
    if (self = [super init]) {
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.filePath = [documentPath stringByAppendingPathComponent:fileName];
        self.serverParams = [[NSDictionary alloc] initWithContentsOfFile:self.filePath];
        if (!self.serverParams){
            self.serverParams = [NSDictionary dictionary];
        }
        [self updateServerDataModel];
    }
    return self;
}

#pragma mark - public method

- (BOOL)saveServerParams:(id <MKLFXServerParamsProtocol>)protocol {
    if (![self checkServerDataProtocol:protocol]) {
        return NO;
    }
    self.serverParams = @{
        @"host":(MKMQTTValidStr(protocol.host) ? protocol.host : @""),
        @"port":(MKMQTTValidStr(protocol.port) ? protocol.port : @""),
        @"clientID":(MKMQTTValidStr(protocol.clientID) ? protocol.clientID : @""),
        @"subscribeTopic":(MKMQTTValidStr(protocol.subscribeTopic) ? protocol.subscribeTopic : @""),
        @"publishTopic":(MKMQTTValidStr(protocol.publishTopic) ? protocol.publishTopic : @""),
        @"cleanSession":@(protocol.cleanSession),
        @"qos":@(protocol.qos),
        @"keepAlive":(MKMQTTValidStr(protocol.keepAlive) ? protocol.keepAlive : @""),
        @"userName":(MKMQTTValidStr(protocol.userName) ? protocol.userName : @""),
        @"password":(MKMQTTValidStr(protocol.password) ? protocol.password : @""),
        @"sslIsOn":@(protocol.sslIsOn),
        @"certificate":@(protocol.certificate),
        @"caFileName":(MKMQTTValidStr(protocol.caFileName) ? protocol.caFileName : @""),
        @"clientFileName":(MKMQTTValidStr(protocol.clientFileName) ? protocol.clientFileName : @""),
    };
    [self updateServerDataModel];
    return [self.serverParams writeToFile:self.filePath atomically:NO];
}

- (BOOL)clearLocalData {
    self.serverParams = @{};
    [self updateServerDataModel];
    return [self.serverParams writeToFile:self.filePath atomically:NO];
}

- (BOOL)paramsCanConnectServer {
    if (!MKMQTTValidStr(self.host) || !MKMQTTValidStr(self.port) || !MKMQTTValidStr(self.keepAlive) || !MKMQTTValidStr(self.clientID)) {
        return NO;
    }
    return YES;
}

#pragma mark - private method
- (void)updateServerDataModel {
    self.host = self.serverParams[@"host"];
    self.port = self.serverParams[@"port"];
    self.clientID = self.serverParams[@"clientID"];
    self.subscribeTopic = self.serverParams[@"subscribeTopic"];
    self.publishTopic = self.serverParams[@"publishTopic"];
    self.cleanSession = [self.serverParams[@"cleanSession"] boolValue];
    self.qos = [self.serverParams[@"qos"] integerValue];
    self.keepAlive = self.serverParams[@"keepAlive"];
    self.userName = self.serverParams[@"userName"];
    self.password = self.serverParams[@"password"];
    self.sslIsOn = [self.serverParams[@"sslIsOn"] boolValue];
    self.certificate = [self.serverParams[@"certificate"] integerValue];
    self.caFileName = self.serverParams[@"caFileName"];
    self.clientFileName = self.serverParams[@"clientFileName"];
}

- (BOOL)checkServerDataProtocol:(id <MKLFXServerParamsProtocol>)protocol {
    if (!MKMQTTValidStr(protocol.host) || protocol.host.length > 64 || ![MKMQTTServerSDKAdopter asciiString:protocol.host]) {
        return NO;
    }
    if (!MKMQTTValidStr(protocol.port) || [protocol.port integerValue] < 0 || [protocol.port integerValue] > 65535) {
        return NO;
    }
    if (!MKMQTTValidStr(protocol.clientID) || protocol.clientID.length > 64 || ![MKMQTTServerSDKAdopter asciiString:protocol.clientID]) {
        return NO;
    }
    if (protocol.publishTopic.length > 128 || (MKMQTTValidStr(protocol.publishTopic) && ![MKMQTTServerSDKAdopter asciiString:protocol.publishTopic])) {
        return NO;
    }
    if (protocol.subscribeTopic.length > 128 || (MKMQTTValidStr(protocol.subscribeTopic) && ![MKMQTTServerSDKAdopter asciiString:protocol.subscribeTopic])) {
        return NO;
    }
    if (protocol.userName.length > 256 || (MKMQTTValidStr(protocol.userName) && ![MKMQTTServerSDKAdopter asciiString:protocol.userName])) {
        return NO;
    }
    if (protocol.password.length > 256 || (MKMQTTValidStr(protocol.password) && ![MKMQTTServerSDKAdopter asciiString:protocol.password])) {
        return NO;
    }
    if (protocol.qos < 0 || protocol.qos > 2) {
        return NO;
    }
    if (!MKMQTTValidStr(protocol.keepAlive) || [protocol.keepAlive integerValue] < 10 || [protocol.keepAlive integerValue] > 120) {
        return NO;
    }
    if (protocol.sslIsOn) {
        if (protocol.certificate < 0 || protocol.certificate > 2) {
            return NO;
        }
        if (protocol.certificate == 1 && !MKMQTTValidStr(protocol.caFileName)) {
            //需要根证书
            return NO;
        }
        if (protocol.certificate == 2 && (!MKMQTTValidStr(protocol.caFileName) || !MKMQTTValidStr(protocol.clientFileName))) {
            //双向验证，需要CA根证书、.p12证书
            return NO;
        }
    }
    
    return YES;
}

@end
