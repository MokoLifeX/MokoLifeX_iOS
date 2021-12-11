//
//  MKLFXASocketInterface.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, lfxa_mqttServerConnectMode) {
    lfxa_mqttServerConnectTCPMode,           //The MQTT server connection mode configured for the plug is TCP
    lfxa_mqttServerConnectOneWaySSLMode,     //The MQTT server connection mode configured for the plug is SSL
    lfxa_mqttServerConnectTwoWaySSLMode,
};

//Quality of MQQT service
typedef NS_ENUM(NSInteger, lfxa_mqttServerQosMode) {
    lfxa_mqttQosLevelAtMostOnce,      //At most once. The message sender to find ways to send messages, but an accident and will not try again.
    lfxa_mqttQosLevelAtLeastOnce,     //At least once.If the message receiver does not know or the message itself is lost, the message sender sends it again to ensure that the message receiver will receive at least one, and of course, duplicate the message.
    lfxa_mqttQosLevelExactlyOnce,     //Exactly once.Ensuring this semantics will reduce concurrency or increase latency, but level 2 is most appropriate when losing or duplicating messages is unacceptable.
};

//Configure the security policy for plug connecting to the ssid-specific WiFi network
typedef NS_ENUM(NSInteger, lfxa_wifiSecurity) {
    lfxa_wifiSecurity_OPEN,
    lfxa_wifiSecurity_WEP,
    lfxa_wifiSecurity_WPA_PSK,
    lfxa_wifiSecurity_WPA2_PSK,
    lfxa_wifiSecurity_WPA_WPA2_PSK,
};

typedef NS_ENUM(NSInteger, lfxa_electricalDefaultState) {
    lfxa_electricalDefaultStateOff,                           //设备上电默认关
    lfxa_electricalDefaultStateOn,                            //设备上电默认开
    lfxa_electricalDefaultStateRemind,                        //设备上电默认断电前的状态
};

@interface MKLFXASocketInterface : NSObject

+ (MKLFXASocketInterface *)shared;

+ (void)sharedDealloc;

- (BOOL)isConnected;

/// Device connection.
/// @param sucBlock Success callback
/// @param failedBlock Failure callback
- (void)connectWithSucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

- (void)disconnect;

/**
 Send the MQTT server information to the plug.If the plug receives this information and successfully parses it, and plug successfully connects to the WiFi network, the plug will automatically connect to the MQTT server specified by the Smartphone.
 
 @param host mqtt   Server host range 1~63
 @param port mqtt   Server port range 0~65535
 @param mode        Connection mode 0: TCP,1: ssl one way,2:ssl two way
 @param qos mqqt    quality of service
 @param keepalive   heartbeat package time, the range is 10~120, and unitis °∞s°±
 @param clean       NO: means to create a persistent session, which remains and saves the offline message until the session expires when the client is disconnected.YES: means to create a new temporary session, which is automatically destroyed when the client disconnects.
 @param clientId    The MQTT server USES the plug as the clientID to distinguish between different plug devices, and if the item is empty, the plug will by default communicate with the MQTT server using the MAC address as the clientID.Device MAC addresses are recommended.length 0~64
 @param username    User name for plug connection to MQTT server, length 0~256
 @param password    Password for  plug connection to MQTT server, length 0~256
 @param sucBlock    Success callback
 @param failedBlock Failed callback
 */
- (void)lfxa_configMQTTServerHost:(NSString *)host
                             port:(NSInteger)port
                      connectMode:(lfxa_mqttServerConnectMode)mode
                              qos:(lfxa_mqttServerQosMode)qos
                        keepalive:(NSInteger)keepalive
                     cleanSession:(BOOL)clean
                         clientId:(NSString *)clientId
                         username:(NSString *)username
                         password:(NSString *)password
                         sucBlock:(void (^)(id returnData))sucBlock
                      failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置CA证书
/// @param certificate CA证书
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configCACertificate:(NSData *)certificate
                        sucBlock:(void (^)(void))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置客户端证书
/// @param certificate 客户端证书
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configClientCertificate:(NSData *)certificate
                            sucBlock:(void (^)(void))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置客户端私钥
/// @param clientKey 客户端私钥
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configClientKey:(NSData *)clientKey
                    sucBlock:(void (^)(void))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备MQTT通信的topic
/// @param subscibeTopic 插座订阅的主题,长度1~128
/// @param publishTopic 插座发布的主题，长度1~128
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configSubscibeTopic:(NSString *)subscibeTopic
                    publishTopic:(NSString *)publishTopic
                        sucBlock:(void (^)(id returnData))sucBlock
                     failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备上电默认状态
/// @param state state
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configElectricalDefaultState:(lfxa_electricalDefaultState)state
                                 sucBlock:(void (^)(id returnData))sucBlock
                              failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备连接的wifi信息
/// @param ssid 1~32个ascii字符
/// @param password 0~64个ascii字符
/// @param security wifi加密策略
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configWifiSSID:(NSString *)ssid
                   password:(NSString *)password
                   security:(lfxa_wifiSecurity)security
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置设备DeviceID
/// @param deviceID 1~32个ascii字符
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxa_configDeviceID:(NSString *)deviceID
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
