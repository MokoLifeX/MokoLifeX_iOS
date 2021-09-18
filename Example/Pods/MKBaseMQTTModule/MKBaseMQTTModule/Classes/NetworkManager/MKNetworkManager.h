//
//  MKNetworkManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

//当前网络状态发生改变通知
extern NSString *const MKNetworkStatusChangedNotification;

@interface MKNetworkManager : NSObject

@property(nonatomic, assign, readonly)AFNetworkReachabilityStatus currentNetStatus;//当前网络状态

+ (MKNetworkManager *)sharedInstance;

/**
 获取当前手机连接的wifi ssid.
 
 @return wifi ssid
 */
+ (NSString *)currentWifiSSID;

/**
 是否已经连接到正确的wifi了，点击连接的时候，必须先连接设备的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给wifi之后才进行mqtt服务器的连接
 注意:目前公司设备的ssid前两位为mk(MK)
 @return YES:target,NO:not target
 */
+ (BOOL)currentWifiIsCorrect;

/**
 当前网络是否可用
 
 @return YES:可用，NO:不可用
 */
- (BOOL)currentNetworkAvailable;
/**
 当前网络是否是wifi
 
 @return YES:wifi，NO:非wifi
 */
- (BOOL)currentNetworkIsWifi;

@end

NS_ASSUME_NONNULL_END
