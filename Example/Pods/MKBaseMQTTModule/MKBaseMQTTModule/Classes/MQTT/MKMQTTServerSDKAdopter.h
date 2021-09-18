//
//  MKMQTTServerSDKAdopter.h
//  MKBaseMQTTModule_Example
//
//  Created by aa on 2021/8/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMQTTServerSDKAdopter : NSObject

/// 将需要发送给设备的json转换成对应的NSData
/*
 转换的过程中会替换掉换行符，但是不会替换掉空格
 */
/// @param dic json
+ (NSData *)parseJsonToData:(NSDictionary *)dic;

/// 判断一个string是否全部是ascii码
/// @param content content
+ (BOOL)asciiString:(NSString *)content;

/// 判断某个字符串是不是uuid
/// @param uuid [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}
+ (BOOL)isUUIDString:(NSString *)uuid;

//判断某个字符串是否全部是十六进制字符
+ (BOOL)hexChar:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
