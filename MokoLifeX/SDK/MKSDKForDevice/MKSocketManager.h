//
//  MKSocketManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/5.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKSocketTaskDefine.h"

//Device default address
extern NSString *const defaultHostIpAddress;
//Device default port
extern NSInteger const defaultPort;

typedef NS_ENUM(NSInteger, mqttServerConnectMode) {
    mqttServerConnectTCPMode,           //The MQTT server connection mode configured for the plug is TCP
    mqttServerConnectOneWaySSLMode,     //The MQTT server connection mode configured for the plug is SSL
    mqttServerConnectTwoWaySSLMode,
};

//Quality of MQQT service
typedef NS_ENUM(NSInteger, mqttServerQosMode) {
    mqttQosLevelAtMostOnce,      //At most once. The message sender to find ways to send messages, but an accident and will not try again.
    mqttQosLevelAtLeastOnce,     //At least once.If the message receiver does not know or the message itself is lost, the message sender sends it again to ensure that the message receiver will receive at least one, and of course, duplicate the message.
    mqttQosLevelExactlyOnce,     //Exactly once.Ensuring this semantics will reduce concurrency or increase latency, but level 2 is most appropriate when losing or duplicating messages is unacceptable.
};

//Configure the security policy for plug connecting to the ssid-specific WiFi network
typedef NS_ENUM(NSInteger, wifiSecurity) {
    wifiSecurity_OPEN,
    wifiSecurity_WEP,
    wifiSecurity_WPA_PSK,
    wifiSecurity_WPA2_PSK,
    wifiSecurity_WPA_WPA2_PSK,
};

typedef NS_ENUM(NSInteger, mk_electricalDefaultState) {
    mk_electricalDefaultStateOff,                           //设备上电默认关
    mk_electricalDefaultStateOn,                            //设备上电默认开
    mk_electricalDefaultStateRemind,                        //设备上电默认断电前的状态
};

@class MKSocketTaskOperation;
@interface MKSocketManager : NSObject

+ (MKSocketManager *)sharedInstance;

- (void)addTaskWithTaskID:(MKSocketOperationID)taskID
               jsonString:(NSString *)jsonString
                 sucBlock:(void (^)(id returnData))sucBlock
              failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Plug connection
 
 @param host         Host ip address
 @param port         port range (0~65535)
 @param sucBlock     Success callback
 @param failedBlock  Failed callback
 */
- (void)connectDeviceWithHost:(NSString *)host
                         port:(NSInteger)port
              connectSucBlock:(void (^)(NSString *IP, NSInteger port))sucBlock
           connectFailedBlock:(void (^)(NSError *error))failedBlock;
/**
 Plug disconnection
 */
- (void)disconnect;
/**
 Read device information
 
 @param sucBlock Connection successful callback
 @param failedBlock Connection failed callback
 */
- (void)readSmartPlugDeviceInformationWithSucBlock:(void (^)(id returnData))sucBlock
                                       failedBlock:(void (^)(NSError *error))failedBlock;
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
- (void)configMQTTServerHost:(NSString *)host
                        port:(NSInteger)port
                 connectMode:(mqttServerConnectMode)mode
                         qos:(mqttServerQosMode)qos
                   keepalive:(NSInteger)keepalive
                cleanSession:(BOOL)clean
                    clientId:(NSString *)clientId
                    username:(NSString *)username
                    password:(NSString *)password
                    sucBlock:(void (^)(id returnData))sucBlock
                 failedBlock:(void (^)(NSError *error))failedBlock;

/**
 配置CA证书

 @param certificate CA证书
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configCACertificate:(NSData *)certificate
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/**
 配置客户端证书

 @param certificate 客户端证书
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configClientCertificate:(NSData *)certificate
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/**
 配置客户端私钥

 @param clientKey 客户端私钥
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configClientKey:(NSData *)clientKey
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

/**
 配置插座与MQTT服务器通信的主题

 @param subscibeTopic 插座订阅的主题,长度1~128
 @param publishTopic 插座发布的主题，长度1~128
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configDeviceMQTTTopic:(NSString *)subscibeTopic
                 publishTopic:(NSString *)publishTopic
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/**
 设置设备上电默认状态

 @param state state
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configEquipmentElectricalDefaultState:(mk_electricalDefaultState)state
                                     sucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

/**
 
 The phone specifies the specific ssid WiFi network to the plug.
 Note: when calling this method, should ensure that the MQTT server information is set to the plug; Otherwise, calling the method will cause an error.
 When the MQTT server information and the wifi information are sent to the plug, the plug will disconnect from the SDK first, then connect to the wifi, and connect to the MQTT server through the specified wifi.
 
 @param ssid        wifi ssid
 @param password    Wifi password, no password required wifi network, password can be blank
 @param security    wifi encryption strategies
 @param sucBlock    Success callback
 @param failedBlock Failed callback
 */
- (void)configWifiSSID:(NSString *)ssid
              password:(NSString *)password
              security:(wifiSecurity)security
              sucBlock:(void (^)(id returnData))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock;

/**
 配置设备MQTT通信唯一识别码，设备在提交到MQTT服务器时候的数据里面会返回该id，多个设备情况下，可以作为当前是哪个设备返回的数据的标示
 
 @param mqttID mqttID,range 0~32
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configMQTTID:(NSString *)mqttID
            sucBlock:(void (^)(id returnData))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

@end
