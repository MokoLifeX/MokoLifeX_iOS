//
//  MKLFXCServerConfigDeviceSettingView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCServerConfigDeviceSettingViewModel : NSObject

@property (nonatomic, copy)NSString *deviceID;

/// 0-64 Characters
@property (nonatomic, copy)NSString *ntpHost;

/// -24~24
@property (nonatomic, assign)NSInteger timeZone;

@end

@protocol MKLFXCServerConfigDeviceSettingViewDelegate <NSObject>

- (void)lfx_mqtt_deviecSetting_deviceIDChanged:(NSString *)deviceID;

- (void)lfx_mqtt_deviecSetting_ntpURLChanged:(NSString *)url;

- (void)lfx_mqtt_deviecSetting_timeZoneChanged:(NSInteger)timeZone;

@end

@interface MKLFXCServerConfigDeviceSettingView : UIView

@property (nonatomic, strong)MKLFXCServerConfigDeviceSettingViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXCServerConfigDeviceSettingViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
