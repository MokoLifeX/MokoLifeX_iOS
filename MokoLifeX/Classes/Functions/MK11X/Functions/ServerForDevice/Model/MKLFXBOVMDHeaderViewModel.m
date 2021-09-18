//
//  MKLFXBOVMDHeaderViewModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBOVMDHeaderViewModel.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@implementation MKLFXBOVMDHeaderViewModel

- (instancetype)init {
    if (self = [super init]) {
        _cleanSession = YES;
        _keepAlive = @"60";
        _qos = 1;
    }
    return self;
}

/// 校验参数，如果不为空则返回对应的参数错误，为空则表明参数正确
- (NSString *)checkParams {
    if (!ValidStr(self.host) || self.host.length > 64 || ![self.host isAsciiString]) {
        return @"Host error";
    }
    if (!ValidStr(self.port) || [self.port integerValue] < 0 || [self.port integerValue] > 65535) {
        return @"Port error";
    }
    if (self.userName.length > 256 || (ValidStr(self.userName) && ![self.userName isAsciiString])) {
        return @"UserName error";
    }
    if (self.password.length > 256 || (ValidStr(self.password) && ![self.password isAsciiString])) {
        return @"Password error";
    }
    if (self.qos < 0 || self.qos > 2) {
        return @"Qos error";
    }
    if (!ValidStr(self.keepAlive) || [self.keepAlive integerValue] < 10 || [self.keepAlive integerValue] > 120) {
        return @"KeepAlive error";
    }
    if (!ValidStr(self.clientID) || self.clientID.length > 64 || ![self.clientID isAsciiString]) {
        return @"ClientID error";
    }
    if (!ValidStr(self.deviceID) || self.deviceID.length > 32 || ![self.deviceID isAsciiString]) {
        return @"DeviceID error";
    }
    if (self.connectMode < 0 || self.connectMode > 2) {
        return @"ConnectMode error";
    }
    return @"";
}

@end
