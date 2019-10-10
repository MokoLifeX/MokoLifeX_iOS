//
//  MKSocketAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKSocketAdopter : NSObject

+ (BOOL)isValidatIP:(NSString *)IPAddress;
+ (BOOL)isClientId:(NSString *)clientId;
+ (BOOL)isUserName:(NSString *)userName;
+ (BOOL)isPassword:(NSString *)password;
+ (BOOL)isDomainName:(NSString *)host;

/**
 NSDictionary to JSON String

 @param dict json
 @return string
 */
+ (NSString *)convertToJsonData:(NSDictionary *)dict;

/**
 JSON String to NSDictionary
 
 @param jsonString string
 @return dic
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
