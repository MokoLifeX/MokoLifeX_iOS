//
//  MKLFXCMQTTInterface+MKLFX117Add.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTInterface+MKLFX117Add.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKLFXCMQTTManager.h"

@implementation MKLFXCMQTTInterface (MKLFX117Add)

+ (void)lfxc_updateFile:(mk_lfxc_updateFileType)fileType
                   host:(NSString *)host
                   port:(NSInteger)port
              catalogue:(NSString *)catalogue
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
    if (port < 0 || port > 65535 || !ValidStr(catalogue) || catalogue.length > 100 || !ValidStr(host) || host.length > 64) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2004),
                              @"id":deviceID,
                              @"data":@{
                                      @"file_type":@(fileType),
                                      @"domain_name":host,
                                      @"port":@(port),
                                      @"file_way":catalogue,
                                      }
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

+ (void)lfxc_configDeviceTimeZone:(NSInteger)timeZone
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
    if (timeZone < -24 || timeZone > 24) {
        [self operationFailedBlockWithMsg:@"Params error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2124),
                              @"id":deviceID,
                              @"data":@{
                                      @"timestamp":@((long long)[[NSDate date] timeIntervalSince1970]),
                                      @"time_zone":@(timeZone),
                                },
                              };
    [[MKLFXCMQTTManager shared] sendData:dataDic
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

@end
