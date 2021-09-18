//
//  MKLFXCColorSettingPickView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXCColorSettingPickViewDelegate <NSObject>

/// 用户选择了color
/// @param colorType 对应的结果如下:
/*
 mk_lfxc_ledColorTransitionDirectly,
 mk_lfxc_ledColorTransitionSmoothly,
 mk_lfxc_ledColorWhite,
 mk_lfxc_ledColorRed,
 mk_lfxc_ledColorGreen,
 mk_lfxc_ledColorBlue,
 mk_lfxc_ledColorOrange,
 mk_lfxc_ledColorCyan,
 mk_lfxc_ledColorPurple,
 */
- (void)lfxc_colorSettingPickViewTypeChanged:(NSInteger)colorType;

@end

@interface MKLFXCColorSettingPickView : UIView

@property (nonatomic, weak)id <MKLFXCColorSettingPickViewDelegate>delegate;

/// 更新当前选中的color
/// @param colorType 对应的结果如下:
/*
 mk_lfxc_ledColorTransitionDirectly,
 mk_lfxc_ledColorTransitionSmoothly,
 mk_lfxc_ledColorWhite,
 mk_lfxc_ledColorRed,
 mk_lfxc_ledColorGreen,
 mk_lfxc_ledColorBlue,
 mk_lfxc_ledColorOrange,
 mk_lfxc_ledColorCyan,
 mk_lfxc_ledColorPurple,
 */
- (void)updateColorType:(NSInteger)colorType;

@end

NS_ASSUME_NONNULL_END
