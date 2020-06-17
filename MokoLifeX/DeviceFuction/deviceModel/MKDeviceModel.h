//
//  MKDeviceModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDeviceNormalDefines.h"

@interface MKDeviceModel : NSObject<MKDeviceModelProtocol>

/**
 设备唯一标识符
 */
@property (nonatomic, copy)NSString *device_id;

/**
 进行MQTT通信的时候，设备身份唯一识别码
 */
@property (nonatomic, copy)NSString *mqttID;

/**
 设备类型，目前有插座和面板
 */
@property (nonatomic, assign)MKDeviceType device_mode;

/**
 保存的时候的设备icon名字
 */
@property (nonatomic, copy)NSString *device_icon;

/**
 设备返回的plug名字
 */
@property (nonatomic, copy)NSString *device_name;

/**
 用户手动添加的在设备列表页面显示的设备名字，device_name是plug自己定义的并且不可修改的字段。如果用户没有添加这个local_name，那么默认的值就是xxxx
 */
@property (nonatomic, copy)NSString *local_name;

/**
 规格，国标cn/美规us/英规bu/欧规eu
 */
@property (nonatomic, copy)NSString *device_specifications;

/**
 设备功能
 */
@property (nonatomic, copy)NSString *device_function;

/**
 MK102和MK112用于区分插座中差异，取值“0”：不带计电量功能；“1”：带计电量功能，MK112和MK114不做区分。MK115带计电量type为2
 */
@property (nonatomic, copy)NSString *device_type;

/**
 订阅主题
 */
@property (nonatomic, copy)NSString *subscribedTopic;

/**
 发布主题
 */
@property (nonatomic, copy)NSString *publishedTopic;

#pragma mark - 业务流程相关

@property (nonatomic, weak)id <MKDeviceModelDelegate>delegate;

@end
