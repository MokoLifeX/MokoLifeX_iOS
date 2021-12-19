//
//  MKLFXCSocketInterface+MKLFX117Add.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSocketInterface+MKLFX117Add.h"

#import "MKLFXSocketManager.h"
#import "MKLFXSocketAdopter.h"
#import "MKLFXSocketDefines.h"

static long const lfxc_socket_configTimeZoneTag = 2021090808;

@implementation MKLFXCSocketInterface (MKLFX117Add)

- (void)lfxc_configTimeZone:(NSInteger)timeZone
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock {
    if (timeZone < -24 || timeZone > 24) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    NSDictionary *json = @{
        @"header":@(4009),
        @"time_zone":@(timeZone)
    };
    NSString *jsonString = [MKLFXSocketAdopter convertToJsonData:json];
    [[MKLFXSocketManager shared] addTaskWithTag:lfxc_socket_configTimeZoneTag
                                           data:jsonString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
}

@end
