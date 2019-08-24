//
//  MKMQTTServerInterface.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKMQTTServerInterface.h"
#import "MKMQTTServerErrorBlockAdopter.h"

@implementation MKMQTTServerInterface

+ (void)updateFile:(MKUpdateFileType)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
             topic:(NSString *)topic
            mqttID:(NSString *)mqttID
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError *error))failedBlock {
    if (port < 0 || port > 65535 || !catalogue || !host) {
        [MKMQTTServerErrorBlockAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSDictionary *dataDic = @{
                              @"msg_id":@(2004),
                              @"id":mqttID,
                              @"data":@{
                                      @"file_type":@(fileType),
                                      @"domain_name":host,
                                      @"port":@(port),
                                      @"file_way":catalogue,
                                      }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)resetDeviceWithTopic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock{
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2003),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                        mqttID:(NSString *)mqttID
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock{
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2005),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

+ (void)configDevicePowerOnStatus:(MKDevicePowerOnStatus)status
                            topic:(NSString *)topic
                           mqttID:(NSString *)mqttID
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock {
    NSDictionary *dataDic = @{
                              @"msg_id":@(2006),
                              @"id":mqttID,
                              @"data":@{
                                      @"switch_state":@(status)
                                      }
                              };
    [[MKMQTTServerManager sharedInstance] sendData:dataDic topic:topic sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)readDevicePowerOnStatusWithTopic:(NSString *)topic
                                  mqttID:(NSString *)mqttID
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock {
    [[MKMQTTServerManager sharedInstance] sendData:@{@"msg_id":@(2007),@"id":mqttID}
                                             topic:topic
                                          sucBlock:sucBlock
                                       failedBlock:failedBlock];
}

@end
