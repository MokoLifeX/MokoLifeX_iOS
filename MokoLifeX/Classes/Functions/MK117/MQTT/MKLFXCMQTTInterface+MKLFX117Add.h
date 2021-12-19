//
//  MKLFXCMQTTInterface+MKLFX117Add.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_lfxc_updateFileType) {
    mk_lfxc_updateFirmware,
    mk_lfxc_updateCAFile,
    mk_lfxc_updateClientCertificate,
    mk_lfxc_updateClientPrivateKey,
};

@interface MKLFXCMQTTInterface (MKLFX117Add)

/**
 Plug OTA upgrade
 
 @param fileType file type
 @param host The IP address or domain name of the new firmware host.1-64 Characters.
 @param port Range 0~65535
 @param catalogue 1-100 Characters.
 @param topic update file topic
 @param deviceID deviceID
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
+ (void)lfxc_updateFile:(mk_lfxc_updateFileType)fileType
                   host:(NSString *)host
                   port:(NSInteger)port
              catalogue:(NSString *)catalogue
               deviceID:(NSString *)deviceID
                  topic:(NSString *)topic
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备的UTC时区，设备会按照该时区重新设置时间
/// @param timeZone -24~24(时区以30分钟为单位,-12~+12)
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_configDeviceTimeZone:(NSInteger)timeZone
                         deviceID:(NSString *)deviceID
                            topic:(NSString *)topic
                         sucBlock:(void (^)(void))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
