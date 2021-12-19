//
//  MKLFXCUpdateDataModel.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCUpdateDataModel.h"

#import "MKLFXCMQTTInterface+MKLFX117Add.h"
#import "MKLFXCDeviceMQTTNotifications.h"

@implementation MKLFXCUpdateDataModel

- (NSString *)updateResultNotificationName {
    return MKLFXCReceiveUpdateResultNotification;
}

- (void)updateFile:(NSInteger)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
          deviceID:(NSString *)deviceID
             topic:(NSString *)topic
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError * _Nonnull))failedBlock {
    [MKLFXCMQTTInterface lfxc_updateFile:fileType
                                    host:host
                                    port:port
                               catalogue:catalogue
                                deviceID:deviceID
                                   topic:topic
                                sucBlock:sucBlock
                             failedBlock:failedBlock];
}

@end
