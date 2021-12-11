//
//  MKLFXBColorSettingPickView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXBColorSettingPickViewDelegate <NSObject>

/// 用户选择了color
/// @param colorType 对应的结果如下:
/*
 mk_lfxb_ledColorTransitionDirectly,
 mk_lfxb_ledColorTransitionSmoothly,
 mk_lfxb_ledColorWhite,
 mk_lfxb_ledColorRed,
 mk_lfxb_ledColorGreen,
 mk_lfxb_ledColorBlue,
 mk_lfxb_ledColorOrange,
 mk_lfxb_ledColorCyan,
 mk_lfxb_ledColorPurple,
 mk_lfxb_ledColorDisable,
 */
- (void)lfxb_colorSettingPickViewTypeChanged:(NSInteger)colorType;

@end

@interface MKLFXBColorSettingPickView : UIView

@property (nonatomic, weak)id <MKLFXBColorSettingPickViewDelegate>delegate;

/// 更新当前选中的color
/// @param colorType 对应的结果如下:
/*
 mk_lfxb_ledColorTransitionDirectly,
 mk_lfxb_ledColorTransitionSmoothly,
 mk_lfxb_ledColorWhite,
 mk_lfxb_ledColorRed,
 mk_lfxb_ledColorGreen,
 mk_lfxb_ledColorBlue,
 mk_lfxb_ledColorOrange,
 mk_lfxb_ledColorCyan,
 mk_lfxb_ledColorPurple,
 mk_lfxb_ledColorDisable,
 */
- (void)updateColorType:(NSInteger)colorType;

@end

NS_ASSUME_NONNULL_END
