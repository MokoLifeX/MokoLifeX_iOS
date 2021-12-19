//
//  MKLFXCDModifyServerModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXCMQTTInterface+MKLFX117DAdd.h"

NS_ASSUME_NONNULL_BEGIN

@class MKLFXCDModifyServerModel;
@interface MKLFXCDUpdateMQTTServerModel : NSObject<lfxc_117d_updateMQTTServerProtocol>

/// mqtt host  1-64 Characters
@property (nonatomic, copy)NSString *mqtt_host;

/// mqtt port   0-65535
@property (nonatomic, assign)NSInteger mqtt_port;

/// 1-64 Characters
@property (nonatomic, copy)NSString *clientID;

/// 1-128 Characters
@property (nonatomic, copy)NSString *subscribeTopic;

/// 1-128 Characters
@property (nonatomic, copy)NSString *publishTopic;

@property (nonatomic, assign)BOOL cleanSession;

/// 0:Qos0 1:Qos1 2:Qos2
@property (nonatomic, assign)NSInteger qos;

/// 10s~120s
@property (nonatomic, assign)NSInteger keepAlive;

/// 0-256 Characters
@property (nonatomic, copy)NSString *mqtt_userName;

/// 0-256 Characters
@property (nonatomic, copy)NSString *mqtt_password;

@property (nonatomic, assign)BOOL sslIsOn;

/// 0:TCP    1:CA signed server certificate     2:CA certificate     3:Self signed certificates
@property (nonatomic, assign)NSInteger connect_mode;

/// Host of the server where the certificate is located.1-64 Characters
@property (nonatomic, copy)NSString *sslHost;

/// Port of the server where the certificate is located.0~65535
@property (nonatomic, assign)NSInteger sslPort;

/// The path of the CA certificate on the ssl certificate server.1-100Characters
@property (nonatomic, copy)NSString *caFilePath;

/// The path of the Client Private Key on the ssl certificate server.1-100Characters
@property (nonatomic, copy)NSString *clientKeyPath;

/// The path of the Client certificate on the ssl certificate server.1-100Characters
@property (nonatomic, copy)NSString *clientCertPath;

/// Ssid of networked wifi.1-32Characters.
@property (nonatomic, copy)NSString *wifiSSID;

/// Password of networked wifi.0-64Characters.
@property (nonatomic, copy)NSString *wifiPassword;

- (instancetype)initWithModifyServerModel:(MKLFXCDModifyServerModel *)serverModel;

@end





@interface MKLFXCDModifyServerModel : NSObject

@property (nonatomic, copy, readonly)NSString *deviceName;

@property (nonatomic, copy, readonly)NSString *deviceID;

@property (nonatomic, copy)NSString *host;

@property (nonatomic, copy)NSString *port;

@property (nonatomic, copy)NSString *clientID;

@property (nonatomic, copy)NSString *subscribeTopic;

@property (nonatomic, copy)NSString *publishTopic;

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

//设备联网信息
@property (nonatomic, copy)NSString *wifiSSID;

@property (nonatomic, copy)NSString *wifiPassword;

- (NSString *)currentSubscribeTopic;

- (NSString *)currentPublishTopic;

- (void)updateServerWithDeviceID:(NSString *)deviceID
                      macAddress:(NSString *)macAddress
                      deviceName:(NSString *)deviceName
                           topic:(NSString *)topic
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
