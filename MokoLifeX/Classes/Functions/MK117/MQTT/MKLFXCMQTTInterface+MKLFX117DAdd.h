//
//  MKLFXCMQTTInterface+MKLFX117DAdd.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol lfxc_117d_updateMQTTServerProtocol <NSObject>

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

@end

@interface MKLFXCMQTTInterface (MKLFX117DAdd)

/// 配置MK117D设备的UTC时区，设备会按照该时区重新设置时间
/// @param timeZone -24~28(时区以30分钟为单位,-12~+14)
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_config117DDeviceTimeZone:(NSInteger)timeZone
                             deviceID:(NSString *)deviceID
                                topic:(NSString *)topic
                             sucBlock:(void (^)(void))sucBlock
                          failedBlock:(void (^)(NSError *error))failedBlock;

/// MQTT server information of the replacement device.
/// @param protocol protocol
/// @param deviceID deviceID,1-32 Characters
/// @param macAddress Mac address of the device
/// @param topic topic 1-128 Characters
/// @param sucBlock Success callback
/// @param failedBlock Failed callback
+ (void)lfxc_configMQTTServer:(id <lfxc_117d_updateMQTTServerProtocol>)protocol
                     deviceID:(NSString *)deviceID
                        topic:(NSString *)topic
                     sucBlock:(void (^)(void))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/// 设备重入网
/// @param deviceID deviceID
/// @param topic topic
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
+ (void)lfxc_reconnectNetworkWithDeviceID:(NSString *)deviceID
                                    topic:(NSString *)topic
                                 sucBlock:(void (^)(void))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
