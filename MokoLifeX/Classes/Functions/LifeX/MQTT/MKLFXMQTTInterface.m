//
//  MKLFXMQTTInterface.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/28.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXMQTTInterface.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXMQTTManager.h"

@implementation MKLFXMQTTInterface

+ (void)lfx_configDeviceSwitchState:(BOOL)isOn
                           deviceID:(NSString *)deviceID
                              topic:(NSString *)topic
                           sucBlock:(void (^)(void))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(topic) || topic.length > 128 || ![topic isAsciiString]) {
        [self operationFailedBlockWithMsg:@"Topic error" failedBlock:failedBlock];
        return;
    }
    if (!ValidStr(deviceID) || deviceID.length > 32 || ![deviceID isAsciiString]) {
        [self operationFailedBlockWithMsg:@"ClientID error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2001),
                              @"id":deviceID,
                              @"data":@{
                                        @"switch_state" : (isOn ? @"on" : @"off"),
                                      }
                              };
    [[MKLFXMQTTManager shared] sendData:dataDic
                                  topic:topic
                               sucBlock:sucBlock
                            failedBlock:failedBlock];
}

#pragma mark - private method
+ (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.LFXMQTTInterface"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    moko_dispatch_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

@end
