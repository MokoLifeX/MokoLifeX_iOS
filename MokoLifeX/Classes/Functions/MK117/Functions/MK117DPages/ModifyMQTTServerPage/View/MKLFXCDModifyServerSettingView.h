//
//  MKLFXCDModifyServerSettingView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCDModifyServerSettingViewModel : NSObject

/// wifi  ssid .1-32Characters.
@property (nonatomic, copy)NSString *ssid;

/// wifi password. 0-64 Characters.
@property (nonatomic, copy)NSString *password;

@end

@protocol MKLFXCDModifyServerSettingViewDelegate <NSObject>

- (void)lfxc_117d_mqtt_modifyDevice_wifiSSIDChanged:(NSString *)ssid;

- (void)lfxc_117d_mqtt_modifyDevice_wifiPasswordChanged:(NSString *)password;

@end

@interface MKLFXCDModifyServerSettingView : UIView

@property (nonatomic, strong)MKLFXCDModifyServerSettingViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXCDModifyServerSettingViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
