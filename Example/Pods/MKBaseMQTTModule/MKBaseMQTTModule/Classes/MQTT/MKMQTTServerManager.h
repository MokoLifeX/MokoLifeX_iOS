//
//  MKMQTTServerManager.h
//  MKBaseMQTTModule_Example
//
//  Created by aa on 2021/8/23.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MQTTClient/MQTTSessionManager.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MKMQTTServerManagerDidChangeStateNotification;

typedef NS_ENUM(NSInteger, MKMQTTSessionManagerState) {
    MKMQTTSessionManagerStateStarting,
    MKMQTTSessionManagerStateConnecting,
    MKMQTTSessionManagerStateError,
    MKMQTTSessionManagerStateConnected,
    MKMQTTSessionManagerStateClosing,
    MKMQTTSessionManagerStateClosed
};

@class MKMQTTServerManager;
@protocol MKMQTTServerProtocol <NSObject>

/** gets called when a new message was received
 @param sessionManager the instance of MQTTSessionManager whose state changed
 @param data the data received, might be zero length
 @param topic the topic the data was published to
 @param retained indicates if the data retransmitted from server storage
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained;

/** gets called when the connection status changes
 @param sessionManager the instance of MQTTSessionManager whose state changed
 @param newState the new connection state of the sessionManager. This will be identical to `sessionManager.state`.
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MKMQTTSessionManagerState)newState;

@optional
/** gets called when a new message was received

 @param data the data received, might be zero length
 @param topic the topic the data was published to
 @param retained indicates if the data retransmitted from server storage
 */
- (void)handleMessage:(NSData *)data
              onTopic:(NSString *)topic
             retained:(BOOL)retained;

/** gets called when a published message was actually delivered
 @param msgID the Message Identifier of the delivered message
 @note this method is called after a publish with qos 1 or 2 only
 */
- (void)messageDelivered:(UInt16)msgID;

/** gets called when a published message was actually delivered
 @param sessionManager the instance of MQTTSessionManager whose state changed
 @param msgID the Message Identifier of the delivered message
 @note this method is called after a publish with qos 1 or 2 only
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID;

@end

@interface MKMQTTServerManager : NSObject

@property (nonatomic, assign, readonly)MKMQTTSessionManagerState managerState;

@property (nonatomic, strong, readonly)NSMutableDictionary *subscriptions;

@property (nonatomic, strong, readonly)NSMutableArray <id <MKMQTTServerProtocol>>*managerList;

+ (MKMQTTServerManager *)shared;

+ (void)singleDealloc;

- (void)loadDataManager:(nonnull id <MKMQTTServerProtocol>)dataManager;

- (BOOL)removeDataManager:(nonnull id <MKMQTTServerProtocol>)dataManager;

/** Connects to the MQTT broker and stores the parameters for subsequent reconnects
 * @param host specifies the hostname or ip address to connect to. Defaults to @"localhost".
 * @param port specifies the port to connect to
 * @param tls specifies whether to use SSL or not
 * @param keepalive The Keep Alive is a time interval measured in seconds. The MQTTClient ensures that the interval between Control Packets being sent does not exceed the Keep Alive value. In the  absence of sending any other Control Packets, the Client sends a PINGREQ Packet.
 * @param clean specifies if the server should discard previous session information.
 * @param auth specifies the user and pass parameters should be used for authenthication
 * @param user an NSString object containing the user's name (or ID) for authentication. May be nil.
 * @param pass an NSString object containing the user's password. If userName is nil, password must be nil as well.
 * @param will indicates whether a will shall be sent
 * @param willTopic the Will Topic is a string, may be nil
 * @param willMsg the Will Message, might be zero length or nil
 * @param willQos specifies the QoS level to be used when publishing the Will Message.
 * @param willRetainFlag indicates if the server should publish the Will Messages with retainFlag.
 * @param clientId The Client Identifier identifies the Client to the Server. If nil, a random clientId is generated.
 * @param securityPolicy A custom SSL security policy or nil.
 * @param certificates An NSArray of the pinned certificates to use or nil.
 * @param protocolLevel Protocol version of the connection.
 * @param connectHandler Called when first connected or if error occurred. It is not called on subsequent internal reconnects.
 */

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(MQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates
    protocolLevel:(MQTTProtocolVersion)protocolLevel
   connectHandler:(MQTTConnectHandler)connectHandler;

/// Disconnect
- (void)disconnect;

/// Subscribe the topic
/// @param topicList topicList
/// @param qosLevel specifies the Quality of Service for the publish. qos can be 0, 1, or 2.
- (void)subscriptions:(NSArray <NSString *>*)topicList qosLevel:(MQTTQosLevel)qosLevel;

/// Unsubscribe the topic.
/// @param topicList topicList
- (void)unsubscriptions:(NSArray <NSString *>*)topicList;

/**
 Send Data.

 @param data data
 @param topic topic
 @param qosLevel specifies the Quality of Service for the publish. qos can be 0, 1, or 2.
 @param sucBlock success callback
 @param failedBlock failed callback
 */
- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        qosLevel:(MQTTQosLevel)qosLevel
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock;

/**
 Send Data.

 @param data data
 @param topic topic
 @param qosLevel specifies the Quality of Service for the publish. qos can be 0, 1, or 2.
 @param sucBlock success callback
 @param failedBlock failed callback
 */
- (void)publishData:(NSData *)data
              topic:(NSString *)topic
           qosLevel:(MQTTQosLevel)qosLevel
           sucBlock:(void (^)(void))sucBlock
        failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
