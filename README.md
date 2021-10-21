# MokoLifeX iOS Software Development Kit Guide

* This SDK support the company’s MokoLifeX series products.When the device enters the AP mode and is connected by the mobile phone, use the SDK to connect and configure the parameters of the device.

# Design instructions

* Our SDK relies on the third-party component of `CocoaAsyncSocket`. When the mobile phone has been connected to the device (the device in AP mode), the developer connects the device in socket mode through the global management class `MKSocketManager`, and configures the relevant device parameters;


# Get Started

### Development environment:

* Xcode9+,Use Xcode9 or high version to develop;
* iOS12,we limit the minimum iOS system version to 12.0；

### Import to Project

CocoaPods

`MokoLifeXSDK` is available through [CocoaPods](https://cocoapods.org)。To install it, simply add the following line to your Podfile,and then import <MokoLifeXSDK/MKSocketManager.h>：

**pod 'MokoLifeXSDK'**


* <font color=#FF0000 face="黑体">!!!!!!On iOS13 and above, Apple add authority control to obtain the SSID of the WIFI hotspot connected to the current mobile phone.  You need add the strings to “info.plist” file of your project: </font>

```
1.Privacy - Location When In Use Usage Description - "your description"。
2.Privacy - Location Usage Description - "your description"。
3.Privacy - Location Always Usage Description - "your description"。
4.Privacy - Location Always and When In Use Usage Description - "your description"。
```


## Start Developing

### Get sharedInstance of Manager

First of all, the developer should get the sharedInstance of Manager:

```
MKSocketManager *manager = [MKSocketManager sharedInstance];
```

#### 1.Connect to device

**When the mobile phone is connected to the device, you can connect through the following methods in `MKSocketManager`:**



```
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
```

#### 2.Configure the parameters of the device

* Configure MQTT server information.

```
/**
 Send the MQTT server information to the plug.If the plug receives this information and successfully parses it, and plug successfully connects to the WiFi network, the plug will automatically connect to the MQTT server specified by the Smartphone.
 
 @param host mqtt   Server host range 1~63
 @param port mqtt   Server port range 0~65535
 @param mode        Connection mode 0: TCP,1: ssl one way,2:ssl two way
 @param qos mqqt    quality of service
 @param keepalive   heartbeat package time, the range is 10~120, and unitis ‘s’
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
```

* Configure the publish and subscribe topic when the socket communicates with the MQTT server.

```
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

```

* Configure the default state of the socket when it is powered on.

```
/**
 Set equipment electrical default state.After electric power equipment to, default state of switch socket.

 @param state state
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configEquipmentElectricalDefaultState:(mk_electricalDefaultState)state
                                     sucBlock:(void (^)(id returnData))sucBlock
                                  failedBlock:(void (^)(NSError *error))failedBlock;

```

* Configure the wifi information of the socket connection.

```
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

```

* The MQTT ID returned when configuring socket communication is to solve the problem that the Alibaba Cloud platform cannot distinguish devices by topic.

```
/**
 The only identification number, equipment configuration equipment MQTT communication inside when submitted to MQTT server data will return the id, multiple devices, which is can be used as the equipment of the data returned.
 
 @param mqttID mqttID,range 0~32
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configMQTTID:(NSString *)mqttID
            sucBlock:(void (^)(id returnData))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

```

* For servers that require SSL authentication, you can configure related information through the following methods:

```
/**
 Config CA File

 @param certificate CA file
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configCACertificate:(NSData *)certificate
                   sucBlock:(void (^)(void))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

```

```
/**
 Config client certificate

 @param certificate client certificate
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configClientCertificate:(NSData *)certificate
                       sucBlock:(void (^)(void))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

```

```
/**
 Config client private key

 @param clientKey client private key
 @param sucBlock Success callback
 @param failedBlock Failed callback
 */
- (void)configClientKey:(NSData *)clientKey
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock;
```


# Change log

* 20210415 first version;
