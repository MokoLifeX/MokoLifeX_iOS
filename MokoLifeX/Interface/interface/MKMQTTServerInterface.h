//
//  MKMQTTServerInterface.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MKUpdateFileType) {
    MKUpdateFirmware,
    MKUpdateCAFile,
    MKUpdateClientCertificate,
    MKUpdateClientPrivateKey,
};

typedef NS_ENUM(NSInteger, MKDevicePowerOnStatus) {
    MKDevicePowerOnStatusOff,
    MKDevicePowerOnStatusOn,
    MKDevicePowerOnStatusRevertLast,
};

@interface MKMQTTServerInterface : NSObject

/**
 Factory Reset
 
 @param topic topic
 @param mqttID mqttID
 @param sucBlock       Success callback
 @param failedBlock    Failed callback
 */
+ (void)resetDeviceWithTopic:(NSString *)topic
                      mqttID:(NSString *)mqttID
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Read device information
 
 @param topic topic
 @param mqttID mqttID
 @param sucBlock      Success callback
 @param failedBlock   Failed callback
 */
+ (void)readDeviceFirmwareInformationWithTopic:(NSString *)topic
                                        mqttID:(NSString *)mqttID
                                      sucBlock:(void (^)(void))sucBlock
                                   failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Plug OTA upgrade
 
 @param fileType file type
 @param host The IP address or domain name of the new firmware host
 @param port Range£∫0~65535
 @param catalogue The length is less than 100 bytes
 @param topic update file topic
 @param mqttID mqttID
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)updateFile:(MKUpdateFileType)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
             topic:(NSString *)topic
            mqttID:(NSString *)mqttID
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError *error))failedBlock;

/**
 When setting equipment electrical switch state by default
 
 @param status status
 @param topic topic
 @param mqttID mqttID
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)configDevicePowerOnStatus:(MKDevicePowerOnStatus)status
                            topic:(NSString *)topic
                           mqttID:(NSString *)mqttID
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Read equipment electrical switch state by default
 
 @param topic topic
 @param mqttID mqttID
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)readDevicePowerOnStatusWithTopic:(NSString *)topic
                                  mqttID:(NSString *)mqttID
                                sucBlock:(void (^)(void))sucBlock
                             failedBlock:(void (^)(NSError *error))failedBlock;

@end
