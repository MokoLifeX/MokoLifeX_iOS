//
//  MKNetworkManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKNetworkManager.h"

#import <SystemConfiguration/CaptiveNetwork.h>

NSString *const MKNetworkStatusChangedNotification = @"MKNetworkStatusChangedNotification";

@interface NSObject (MKNetworkManager)

@end

@implementation NSObject (MKNetworkManager)

+ (void)load{
    [MKNetworkManager sharedInstance];
}

@end

@interface MKNetworkManager()

@property(nonatomic, assign)AFNetworkReachabilityStatus currentNetStatus;//当前网络状态

@end

@implementation MKNetworkManager

+ (MKNetworkManager *)sharedInstance{
    static MKNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKNetworkManager new];
            [manager startMonitoring];
        }
    });
    return manager;
}

#pragma mark - public method

+ (NSString *)currentWifiSSID{
    CFArrayRef tempArray = CNCopySupportedInterfaces();
    if (!tempArray) {
        return @"<<NONE>>";
    }
    CFStringRef interfaceName = CFArrayGetValueAtIndex(tempArray, 0);
    CFDictionaryRef captiveNtwrkDict = CNCopyCurrentNetworkInfo(interfaceName);
    NSDictionary* wifiDic = (__bridge NSDictionary *) captiveNtwrkDict;
    if (!wifiDic || wifiDic.allValues.count == 0) {
        CFRelease(tempArray);
        return @"<<NONE>>";
    }
    CFRelease(tempArray);
    return wifiDic[@"SSID"];
}

+ (BOOL)currentWifiIsCorrect {
    if ([MKNetworkManager sharedInstance].currentNetStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
        return NO;
    }
    NSString *wifiSSID = [self currentWifiSSID];
    if (!wifiSSID || ![wifiSSID isKindOfClass:NSString.class] || wifiSSID.length == 0 || [wifiSSID isEqualToString:@"<<NONE>>"] || wifiSSID.length < 2) {
        //当前wifi的ssid未知
        return NO;
    }
    NSString *ssidHeader = [[wifiSSID substringWithRange:NSMakeRange(0, 2)] uppercaseString];
    if ([ssidHeader isEqualToString:@"MK"]) {
        return YES;
    }
    return NO;
}

- (BOOL)currentNetworkAvailable{
    if (self.currentNetStatus == AFNetworkReachabilityStatusUnknown
        || self.currentNetStatus == AFNetworkReachabilityStatusNotReachable) {
        return NO;
    }
    return YES;
}

- (BOOL)currentNetworkIsWifi{
    return (self.currentNetStatus == AFNetworkReachabilityStatusReachableViaWiFi);
}

#pragma mark 网络监听相关方法
- (void)startMonitoring{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        self.currentNetStatus = status;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKNetworkStatusChangedNotification object:nil];
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
