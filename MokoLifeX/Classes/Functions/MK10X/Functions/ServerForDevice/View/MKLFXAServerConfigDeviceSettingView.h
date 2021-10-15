//
//  MKLFXAServerConfigDeviceSettingView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXAServerConfigDeviceSettingViewModel : NSObject

@property (nonatomic, copy)NSString *deviceID;

/// 0-64 Characters
@property (nonatomic, copy)NSString *ntpHost;

/// -24~24
@property (nonatomic, assign)NSInteger timeZone;

@end

@protocol MKLFXAServerConfigDeviceSettingViewDelegate <NSObject>

- (void)lfxa_mqtt_deviecSetting_deviceIDChanged:(NSString *)deviceID;

@end

@interface MKLFXAServerConfigDeviceSettingView : UIView

@property (nonatomic, strong)MKLFXAServerConfigDeviceSettingViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXAServerConfigDeviceSettingViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
