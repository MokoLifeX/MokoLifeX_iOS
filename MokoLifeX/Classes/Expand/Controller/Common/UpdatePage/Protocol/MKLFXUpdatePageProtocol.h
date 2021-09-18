//
//  MKLFXUpdatePageProtocol.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXUpdatePageProtocol <NSObject>

/// 升级结果通知的名称
- (NSString *)updateResultNotificationName;

/// 开启设备升级
/// @param fileType 0:Firmware     1:CA certification      2:Client certification        3:Client key
/// @param host host
/// @param port port
/// @param catalogue 目录地址
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)updateFile:(NSInteger)fileType
              host:(NSString *)host
              port:(NSInteger)port
         catalogue:(NSString *)catalogue
          deviceID:(NSString *)deviceID
             topic:(NSString *)topic
          sucBlock:(void (^)(void))sucBlock
       failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
