//
//  MKLFXSocketManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//Device default address
extern NSString *const lfx_defaultHostIpAddress;
//Device default port
extern NSInteger const lfx_defaultPort;

//socket disconnect
extern NSString *const lfx_socket_deviceDisconnectNotification;

@interface MKLFXSocketManager : NSObject

@property (nonatomic, assign, readonly, getter=currentSocketStatus)BOOL isConnected;

+ (MKLFXSocketManager *)shared;

+ (void)sharedDealloc;

/// Device connection.
/// @param host Host ip address
/// @param port port(0~65535)
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)connectWithHost:(NSString *)host
                   port:(NSInteger)port
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

- (void)disconnect;

/// Start a task for data communication with the device
/// @param tag operation tag
/// @param data data
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)addTaskWithTag:(long)tag
                  data:(NSString *)data
              sucBlock:(void (^)(id returnData))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

/// Read device information
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)readDeviceInfoWithSucBlock:(void (^)(id returnData))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
