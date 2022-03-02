//
//  MKLFXCSocketInterface+MKLFX117DAdd.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSocketInterface+MKLFX117DAdd.h"

#import "MKLFXSocketManager.h"
#import "MKLFXSocketAdopter.h"
#import "MKLFXSocketDefines.h"

static long const lfxc_socket_config117DTimeZoneTag = 2021121701;
static long const lfxc_socket_config117DChannelTag = 2021121702;
static long const lfxc_socket_read117DChannelTag = 2021121703;
static long const lfxc_socket_read117DTimeZoneTag = 2021121704;

@implementation MKLFXCSocketInterface (MKLFX117DAdd)

- (void)lfxc_read117DTimeZoneWithSucBlock:(void (^)(id returnData))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock {
         NSDictionary *json = @{
             @"header":@(4012),
         };
         NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
         [[MKLFXSocketManager shared] addTaskWithTag:lfxc_socket_read117DTimeZoneTag
                                                data:jsonString
                                            sucBlock:sucBlock
                                         failedBlock:failedBlock];
     }

- (void)lfxc_readChannelWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock {
    NSDictionary *json = @{
        @"header":@(4013),
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxc_socket_read117DChannelTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

- (void)lfxc_config117DTimeZone:(NSInteger)timeZone
                       sucBlock:(void (^)(id returnData))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock {
    if (timeZone < -24 || timeZone > 28) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *json = @{
        @"header":@(4010),
        @"time_zone":@(timeZone)
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxc_socket_config117DTimeZoneTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

- (void)lfxc_configChannel:(NSInteger)channel
                  sucBlock:(void (^)(id returnData))sucBlock
               failedBlock:(void (^)(NSError *error))failedBlock {
    if (channel < 0 || channel > 21) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *json = @{
        @"header":@(4011),
        @"channel_plan":@(channel)
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxc_socket_config117DChannelTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

@end
