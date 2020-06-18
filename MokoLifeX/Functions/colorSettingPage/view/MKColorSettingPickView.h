//
//  MKColorSettingPickView.h
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKColorSettingPickViewDelegate <NSObject>

- (void)colorSettingPickViewTypeChanged:(mk_ledColorType)colorType;

@end

@interface MKColorSettingPickView : UIView

@property (nonatomic, weak)id <MKColorSettingPickViewDelegate>delegate;

- (void)updateColorType:(mk_ledColorType)colorType;

@end

NS_ASSUME_NONNULL_END
