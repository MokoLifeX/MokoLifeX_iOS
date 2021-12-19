//
//  MKLFXCDModifyServerFooterView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCDModifyServerFooterViewModel : NSObject

@property (nonatomic, assign)BOOL cleanSession;

@property (nonatomic, assign)NSInteger qos;

@property (nonatomic, copy)NSString *keepAlive;

@property (nonatomic, copy)NSString *userName;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, assign)BOOL sslIsOn;

/// 0:CA signed server certificate     1:CA certificate     2:Self signed certificates
@property (nonatomic, assign)NSInteger certificate;

/// 证书所在服务器Host
@property (nonatomic, copy)NSString *sslHost;

/// 证书所在服务器Port
@property (nonatomic, copy)NSString *sslPort;

@property (nonatomic, copy)NSString *caFilePath;

@property (nonatomic, copy)NSString *clientKeyPath;

@property (nonatomic, copy)NSString *clientCertPath;

/// wifi  ssid .1-32Characters.
@property (nonatomic, copy)NSString *wifiSSID;

/// wifi password. 0-64 Characters.
@property (nonatomic, copy)NSString *wifiPassword;

@end

@protocol MKLFXCDModifyServerFooterViewDelegate <NSObject>

/// 用户改变了开关状态
/// @param isOn isOn
/// @param statusID 0:cleanSession   1:ssl
- (void)lfxc_117d_mqtt_modifyMQTT_switchStatusChanged:(BOOL)isOn statusID:(NSInteger)statusID;

/// 输入框内容发生了改变
/// @param text 最新的输入框内容
/// @param textID 0:keepAlive    1:userName     2:password    3:wifiSSID   4:Password  5:sslHost    6:sslPort   7:CA File Path    8:Client Key File   9:Client Cert  File
- (void)lfxc_117d_mqtt_modifyMQTT_textFieldValueChanged:(NSString *)text textID:(NSInteger)textID;

- (void)lfxc_117d_mqtt_modifyMQTT_qosChanged:(NSInteger)qos;

/// 用户选择了加密方式
/// @param certificate 0:CA signed server certificate     1:CA certificate     2:Self signed certificates
- (void)lfxc_117d_mqtt_modifyMQTT_certificateChanged:(NSInteger)certificate;

@end

@interface MKLFXCDModifyServerFooterView : UIView

@property (nonatomic, strong)MKLFXCDModifyServerFooterViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXCDModifyServerFooterViewDelegate>delegate;

/// 动态刷新高度
/// @param isOn ssl开关是否打开
/// @param certificate 当前ssl加密规则
- (CGFloat)fetchHeightWithSSLStatus:(BOOL)isOn
                        certificate:(NSInteger)certificate;

@end

NS_ASSUME_NONNULL_END
