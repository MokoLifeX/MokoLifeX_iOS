//
//  MKLFXServerForAppModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXServerForAppModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXServerManager.h"

@implementation MKLFXServerForAppModel

- (instancetype)init {
    if (self = [super init]) {
        [self loadServerParams];
    }
    return self;
}

- (void)clearAllParams {
    _host = @"";
    _port = @"";
    _clientID = @"";
    _subscribeTopic = @"";
    _publishTopic = @"";
    _cleanSession = NO;
    _qos = 0;
    _keepAlive = @"";
    _userName = @"";
    _password = @"";
    _sslIsOn = NO;
    _certificate = 0;
    _caFileName = @"";
    _clientFileName = @"";
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
    if (self.publishTopic.length > 128 || (ValidStr(self.publishTopic) && ![self.publishTopic isAsciiString])) {
        return @"PublishTopic error";
    }
    if (self.subscribeTopic.length > 128 || (ValidStr(self.subscribeTopic) && ![self.subscribeTopic isAsciiString])) {
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
            if (self.certificate == 2 && !ValidStr(self.clientFileName)) {
                return @"Client File cannot be empty.";
            }
        }
    }
    return @"";
}

#pragma mark - private method
- (void)loadServerParams {
    if (!ValidStr([MKLFXServerManager shared].serverParams.host)) {
        //本地没有服务器参数
        self.cleanSession = YES;
        self.keepAlive = @"60";
        self.qos = 1;
        return;
    }
    self.host = [MKLFXServerManager shared].serverParams.host;
    self.port = [MKLFXServerManager shared].serverParams.port;
    self.clientID = [MKLFXServerManager shared].serverParams.clientID;
    self.subscribeTopic = [MKLFXServerManager shared].serverParams.subscribeTopic;
    self.publishTopic = [MKLFXServerManager shared].serverParams.publishTopic;
    self.cleanSession = [MKLFXServerManager shared].serverParams.cleanSession;
    
    self.qos = [MKLFXServerManager shared].serverParams.qos;
    self.keepAlive = [MKLFXServerManager shared].serverParams.keepAlive;
    self.userName = [MKLFXServerManager shared].serverParams.userName;
    self.password = [MKLFXServerManager shared].serverParams.password;
    self.sslIsOn = [MKLFXServerManager shared].serverParams.sslIsOn;
    self.certificate = [MKLFXServerManager shared].serverParams.certificate;
    self.caFileName = [MKLFXServerManager shared].serverParams.caFileName;
    self.clientFileName = [MKLFXServerManager shared].serverParams.clientFileName;
}

@end
