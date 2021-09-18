//
//  MKLFXDeviceModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MKLFXDeviceModelState) {
    MKLFXDeviceModelStateOffline,               //离线
    MKLFXDeviceModelStateOn,                    //开关打开
    MKLFXDeviceModelStateOff,                   //开关关闭
};

//对于MK117、MK117D设备，是否处于过载、过流、过压状态
typedef NS_ENUM(NSInteger, MKLFXDeviceOverState) {
    MKLFXDeviceOverState_normal,            //正常状态
    MKLFXDeviceOverState_overLoad,          //过载状态
    MKLFXDeviceOverState_overCurrent,       //过流状态
    MKLFXDeviceOverState_overVoltage,       //过压状态
};

//当设备离线的时候发出通知
extern NSString *const MKLFXDeviceModelOfflineNotification;

@protocol MKLFXDeviceModelDelegate <NSObject>

/// 当前设备离线
/// @param deviceID 当前设备的deviceID
- (void)lfx_deviceOfflineWithDeviceID:(NSString *)deviceID;

@end

@interface MKLFXDeviceModel : NSObject

/**
 数据交互可能存在多个设备订阅同一个topic的情况，这个时候只能通过deviceID区分设备，所以统一为topic+deviceID来区分通信数据
 */
@property (nonatomic, copy)NSString *deviceID;

/// MTQQ通信所需的ID，如果存在重复的，会出现交替上线的情况
@property (nonatomic, copy)NSString *clientID;

/**
 mac地址,对应设备读取信息参数的device_id
 */
@property (nonatomic, copy)NSString *macAddress;

/**
 设备广播名字
 */
@property (nonatomic, copy)NSString *deviceName;

///  MK102和MK112用于区分插座中差异，取值“0”：不带计电量功能；“1”：带计电量功能，MK112和MK114不做区分。MK115带计电量type为2
///MK116为3，MK117为4，MK117D为5.
@property (nonatomic, copy)NSString *deviceType;

/**
 订阅主题,当用户设置了app的订阅主题时，返回设置的订阅主题，否则返回当前model的订阅主题
 */
@property (nonatomic, copy)NSString *subscribedTopic;

/**
 发布主题,当用户设置了app的发布主题时，返回设置的发布主题，否则返回当前model的发布主题
 */
@property (nonatomic, copy)NSString *publishedTopic;

@property (nonatomic, assign)MKLFXDeviceModelState state;

/// 对于MK117、MK117D设备，是否处于过载、过流、过压状态
@property (nonatomic, assign)MKLFXDeviceOverState overState;

#pragma mark - 业务流程相关

@property (nonatomic, weak)id <MKLFXDeviceModelDelegate>delegate;

- (NSString *)currentSubscribedTopic;

- (NSString *)currentPublishedTopic;

/**
 设备列表页面的状态监控
 */
- (void)startStateMonitoringTimer;

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter;

/**
 取消定时器
 */
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
