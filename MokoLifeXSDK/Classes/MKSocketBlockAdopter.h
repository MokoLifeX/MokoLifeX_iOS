//
//  MKSocketBlockAdopter.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Custom Error Code
 */
typedef NS_ENUM(NSInteger, socketCustomErrorCode){
    socketNoError = 0,
    socketNetworkDisable = -10000,                                  //Network inaccessible
    socketConnectedFailed = -10001,                                 //Connecting peripherals failure
    socketDisconnected = -10002,                                    //Peripherals disconnected
    socketRequestDataError = -10003,                                //Request data failure
    socketParamsError = -10004,                                     //The input parameters error
    socketSetParamsError = -10005,                                  //Config parameters error
};

@interface MKSocketBlockAdopter : NSObject

+ (NSError *)getErrorWithCode:(socketCustomErrorCode)code message:(NSString *)message;

+ (NSError *)exchangedGCDAsyncSocketErrorToLocalError:(NSError *)error;

+ (void)operationParamsErrorBlock:(void (^)(NSError *error))block;

+ (void)operationParamsErrorWithMessage:(NSString *)message block:(void (^)(NSError *error))block;

+ (void)operationGetDataErrorBlock:(void (^)(NSError *error))block;

+ (void)operationDisConnectedErrorBlock:(void (^)(NSError *error))block;

+ (void)operationDataErrorWithReturnData:(NSDictionary *)returnData block:(void (^)(NSError *error))block;

+ (void)operationConnectTimeoutBlock:(void (^)(NSError *error))block;

@end
