//
//  MKLFXSocketAdopter.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/26.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXSocketAdopter : NSObject

+ (BOOL)isValidatIP:(NSString *)IPAddress;

/**
 字典转json字符串方法

 @param dict json
 @return string
 */
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

/**
 JSON字符串转化为字典
 
 @param jsonString string
 @return dic
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
