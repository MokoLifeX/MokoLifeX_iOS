//
//  MKLFXServerManager.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MKBaseMQTTModule/MKMQTTServerManager.h>

#import "MKLFXServerConfigDefines.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MKLFXMQTTSessionManagerStateChangedNotification;

@interface MKLFXServerManager : NSObject<MKMQTTServerProtocol>

@property (nonatomic, assign, readonly)MKLFXMQTTSessionManagerState state;

@property (nonatomic, strong, readonly, getter=currentServerParams)id <MKLFXServerParamsProtocol>serverParams;

@property (nonatomic, strong, readonly)NSMutableArray <id <MKLFXServerManagerProtocol>>*managerList;

+ (MKLFXServerManager *)shared;

/// 销毁单例
+ (void)singleDealloc;

/// 将一个满足MKLFXServerManagerProtocol的对象加入到管理列表
/// @param dataManager MKLFXServerManagerProtocol
- (void)loadDataManager:(nonnull id <MKLFXServerManagerProtocol>)dataManager;

/// 将满足MKLFXServerManagerProtocol的对象移除管理列表
/// @param dataManager MKLFXServerManagerProtocol的对象
- (BOOL)removeDataManager:(nonnull id <MKLFXServerManagerProtocol>)dataManager;

/// 将参数保存到本地，下次启动通过该参数连接服务器
/// @param protocol protocol
- (BOOL)saveServerParams:(id <MKLFXServerParamsProtocol>)protocol;

/**
 清除本地记录的设置信息
 */
- (BOOL)clearLocalData;

#pragma mark - *****************************服务器交互部分******************************

/// 开始连接服务器，前提是必须服务器参数不能为空
- (BOOL)connect;

/**
 Subscribe the topic

 @param topicList topicList
 */
- (void)subscriptions:(NSArray <NSString *>*)topicList;

/**
 Unsubscribe the topic
 
 @param topicList topicList
 */
- (void)unsubscriptions:(NSArray <NSString *>*)topicList;

- (void)sendData:(NSDictionary *)data
           topic:(NSString *)topic
        sucBlock:(void (^)(void))sucBlock
     failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
