//
//  MKLaunchScreenView.m
//  MokoLifeXSDK_Example
//
//  Created by aa on 2019/9/28.
//  Copyright © 2019 aadyx2007@163.com. All rights reserved.
//

#import "MKLaunchScreenView.h"

static CGFloat const removeButtonWidth = 40.f;
static CGFloat const removeButtonHeight = 40.f;

@interface MKLaunchScreenView ()

@property (nonatomic, strong)UIButton *removeButton;

@end

@implementation MKLaunchScreenView

- (void)dealloc {
    NSLog(@"MKLaunchScreenView销毁");
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = COLOR_WHITE_MACROS;
        self.userInteractionEnabled = YES;
        [self addSubview:self.removeButton];
    }
    return self;
}

#pragma mark - event method
- (void)removeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(launchScreenViewRemoveButtonPressed)]) {
        [self.delegate launchScreenViewRemoveButtonPressed];
    }
}

#pragma mark - setter & getter
- (UIButton *)removeButton {
    if (!_removeButton) {
        _removeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 15.f - removeButtonWidth, defaultTopInset, removeButtonWidth, removeButtonHeight)];
        [_removeButton setBackgroundColor:RGBACOLOR(0, 0, 0, 0.3)];
        [_removeButton.titleLabel setFont:MKFont(14.f)];
        [_removeButton setTitle:@"跳过" forState:UIControlStateNormal];
        [_removeButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_removeButton.layer setMasksToBounds:YES];
        [_removeButton.layer setCornerRadius:(removeButtonWidth / 2)];
        [_removeButton addTapAction:self selector:@selector(removeButtonPressed)];
    }
    return _removeButton;
}

@end
