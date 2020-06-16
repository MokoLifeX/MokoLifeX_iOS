//
//  MKColorSettingPickView.h
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_ledColorType) {
    mk_ledColorTransitionSmoothly,
    mk_ledColorTransitionDirectly,
    mk_ledColorWhite,
    mk_ledColorRed,
    mk_ledColorGreen,
    mk_ledColorBlue,
    mk_ledColorOrange,
    mk_ledColorCyan,
    mk_ledColorPurple,
    mk_ledColorDisable,
};

@protocol MKColorSettingPickViewDelegate <NSObject>

- (void)colorSettingPickViewTypeChanged:(mk_ledColorType)colorType;

@end

@interface MKColorSettingPickView : UIView

@property (nonatomic, weak)id <MKColorSettingPickViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
