//
//  MKLFXSocketAdopter.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/26.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXSocketAdopter.h"

#import "MKLFXSocketDefines.h"

@implementation MKLFXSocketAdopter

+ (BOOL)isValidatIP:(NSString *)IPAddress{
    NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [pred evaluateWithObject:IPAddress];
}

+ (NSString *)convertToJsonData:(NSDictionary *)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        return @"";
    }
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (!MKSKValidStr(jsonString)) {
        return @{};
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return @{};
    }
    return dic;
}

@end
