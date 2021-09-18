//
//  MKMQTTServerSDKAdopter.m
//  MKBaseMQTTModule_Example
//
//  Created by aa on 2021/8/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKMQTTServerSDKAdopter.h"

#import "MKMQTTServerSDKDefines.h"

@implementation MKMQTTServerSDKAdopter

+ (NSData *)parseJsonToData:(NSDictionary *)dic {
    if (!MKMQTTValidDict(dic)) {
        return [NSData data];
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (!jsonData) {
        return [NSData data];
    }
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (!MKMQTTValidStr(jsonString)) {
        return [NSData data];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
//    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    return [mutStr dataUsingEncoding:NSUTF8StringEncoding];
}

+ (BOOL)asciiString:(NSString *)content {
    NSInteger strlen = content.length;
    NSInteger datalen = [[content dataUsingEncoding:NSUTF8StringEncoding] length];
    if (strlen != datalen) {
        return NO;
    }
    return YES;
}

+ (BOOL)isUUIDString:(NSString *)uuid{
    NSString *uuidPatternString = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:uuidPatternString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSInteger numberOfMatches = [regex numberOfMatchesInString:uuid
                                                       options:kNilOptions
                                                         range:NSMakeRange(0, uuid.length)];
    return (numberOfMatches > 0);
}

+ (BOOL)hexChar:(NSString *)content {
    if (!MKMQTTValidStr(content)) {
        return NO;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[a-fA-F0-9]*"];
    return [pred evaluateWithObject:content];
}

@end
