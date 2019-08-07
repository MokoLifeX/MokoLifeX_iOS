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

@end
