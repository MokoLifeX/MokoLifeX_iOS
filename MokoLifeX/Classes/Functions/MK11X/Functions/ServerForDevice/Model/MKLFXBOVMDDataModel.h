//
//  MKLFXBOVMDDataModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MKLFXBOVMDHeaderViewModel;
@interface MKLFXBOVMDDataModel : NSObject

@property (nonatomic, strong)MKLFXBOVMDHeaderViewModel *headerModel;

#pragma mark - 注意，下面这几个证书名字与headerModel里面的connectMode存在关联性，如果connectMode=0，则下面三个证书都不需要，connectMode=1，则需要caFileName证书，如果connectMode=2则下面三个证书都需要

/// 根证书名字
@property (nonatomic, copy)NSString *caFileName;

/// 客户端私钥
@property (nonatomic, copy)NSString *clientKeyName;

/// 客户端证书
@property (nonatomic, copy)NSString *clientCertName;

/// 设备订阅的topic
@property (nonatomic, copy)NSString *subscribeTopic;

/// 设备发布的topic
@property (nonatomic, copy)NSString *publishTopic;

/// 校验参数，如果不为空则返回对应的参数错误，为空则表明参数正确
- (NSString *)checkParams;

/// 给设备配网
/// @param wifiSSID wifi
/// @param wifiPassword wifi的密码
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)configDeviceWithWifiSSID:(NSString *)wifiSSID
                    wifiPassword:(NSString *)wifiPassword
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
