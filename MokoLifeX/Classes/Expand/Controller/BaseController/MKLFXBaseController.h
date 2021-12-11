//
//  MKLFXBaseController.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/1.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseViewController.h>

NS_ASSUME_NONNULL_BEGIN

@class MKLFXDeviceModel;
@interface MKLFXBaseController : MKBaseViewController

/**
 超时标记
 */
@property (nonatomic, assign, readonly)BOOL readTimeout;

@property (nonatomic, strong)MKLFXDeviceModel *deviceModel;

/// 每次读取数据的时候需要开启定时器,10s之内没有收到设备回复的信息，则认为读取超时
- (void)startReadTimer;

/// 读取定时器超时
- (void)readDataTimeout;

/// 取消定时器
- (void)cancelTimer;

@end

NS_ASSUME_NONNULL_END
