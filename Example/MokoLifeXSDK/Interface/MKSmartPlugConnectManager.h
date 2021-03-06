//
//  MKSmartPlugConnectManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKConfigServerModel;
@interface MKSmartPlugConnectManager : NSObject

/**
 连接plug设备并且配置各项参数过程，配置成功之后，该设备会存储到本地数据库
 
 @param wifi_ssid 指定plug连接的wifi ssid
 @param password 指定plug连接的wifi password，对于没有密码的wifi，该项参数可以不填
 @param serverModel 配置项
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configDeviceWithWifiSSID:(NSString *)wifi_ssid
                        password:(NSString *)password
                     serverModel:(MKConfigServerModel *)serverModel
                        sucBlock:(void (^)(NSDictionary *deviceInfo))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

@end
