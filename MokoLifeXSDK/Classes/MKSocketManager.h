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
 Config CA File

 @param certificate CA file
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configCACertificate:(NSData *)certificate
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Config client certificate

 @param certificate client certificate
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configClientCertificate:(NSData *)certificate
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Config client private key

 @param clientKey client private key
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configClientKey:(NSData *)clientKey
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Config topic

 @param subscibeTopic Subscribe Topic ,1~128
 @param publishTopic Publish Topic，1~128
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configDeviceMQTTTopic:(NSString *)subscibeTopic
                 publishTopic:(NSString *)publishTopic
                     sucBlock:(void (^)(id returnData))sucBlock
                  failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Set equipment electrical default state.After electric power equipment to, default state of switch socket.

 @param state state
 @param sucBlock Success callback
 @param failedBlock Failed callback
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
 The only identification number, equipment configuration equipment MQTT communication inside when submitted to MQTT server data will return the id, multiple devices, which is can be used as the equipment of the data returned.
 
 @param mqttID mqttID,range 0~32
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configMQTTID:(NSString *)mqttID
            sucBlock:(void (^)(id returnData))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

@end
