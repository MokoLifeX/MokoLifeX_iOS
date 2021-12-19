//
//  MKLFXCDServerConfigDeviceSettingView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCDServerConfigDeviceSettingViewModel : NSObject

@property (nonatomic, copy)NSString *deviceID;

/// 0-64 Characters
@property (nonatomic, copy)NSString *ntpHost;

/// -24~28
@property (nonatomic, assign)NSInteger timeZone;

/// 0~21
@property (nonatomic, assign)NSInteger domain;

@end

@protocol MKLFXCDServerConfigDeviceSettingViewDelegate <NSObject>

- (void)lfxc_mqtt_deviecSetting_117D_deviceIDChanged:(NSString *)deviceID;

- (void)lfxc_mqtt_deviecSetting_117D_ntpURLChanged:(NSString *)url;

- (void)lfxc_mqtt_deviecSetting_117D_timeZoneChanged:(NSInteger)timeZone;

- (void)lfxc_mqtt_deviecSetting_117D_domainChanged:(NSInteger)domain;

@end

@interface MKLFXCDServerConfigDeviceSettingView : UIView

@property (nonatomic, strong)MKLFXCDServerConfigDeviceSettingViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXCDServerConfigDeviceSettingViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
