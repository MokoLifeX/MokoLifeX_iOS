//
//  MKDeviceModel+MKTopic.h
//  MKSmartPlug
//
//  Created by aa on 2018/9/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@interface MKDeviceModel (MKTopic)

/**
 是否已经连接到正确的wifi了，点击连接的时候，必须先连接设备的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给wifi之后才进行mqtt服务器的连接
 
 @return YES:target,NO:not target
 */
+ (BOOL)currentWifiIsCorrect:(MKDeviceType)deviceType;

/**
 当前model的订阅主题，当用户设置了app的订阅主题时，返回设置的订阅主题，否则返回当前model的订阅主题
 
 @return subscribedTopic
 */
- (NSString *)currentSubscribedTopic;

/**
 当前model的发布主题，当用户设置了app的发布主题时，返回设置的发布主题，否则返回当前model的发布主题
 
 @return publishedTopic
 */
- (NSString *)currentPublishedTopic;

@end
