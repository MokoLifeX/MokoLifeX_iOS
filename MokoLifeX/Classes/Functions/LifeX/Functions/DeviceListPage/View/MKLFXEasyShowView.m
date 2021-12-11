//
//  MKLFXEasyShowView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXEasyShowView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKCustomUIAdopter.h"

@interface MKLFXEasyShowView ()

@property (nonatomic, strong)UIImageView *refreshIcon;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, assign)BOOL animated;

@end

@implementation MKLFXEasyShowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = NAVBAR_COLOR_MACROS;
        [self addSubview:self.refreshIcon];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.animated) {
        [self.refreshIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.msgLabel.mas_left).mas_offset(-2.f);
            make.width.mas_equalTo(20.f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(20.f);
        }];
        [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo(120.f);
            make.centerY.mas_equalTo(self.mas_centerY);
            make.height.mas_equalTo(MKFont(18.f).lineHeight);
        }];
        return;
    }
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(2.f);
        make.right.mas_equalTo(-2.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
}

#pragma mark - public method
- (void)showText:(NSString *)text
       superView:(UIView *)superView
        animated:(BOOL)animated {
    if (!superView) {
        return;
    }
    if (self.superview) {
        [self removeFromSuperview];
    }
    [superView addSubview:self];
    self.frame = superView.bounds;
    self.animated = animated;
    [self.refreshIcon.layer removeAllAnimations];
    if (animated) {
        self.refreshIcon.hidden = NO;
        [self.refreshIcon.layer addAnimation:[MKCustomUIAdopter refreshAnimation:1.f] forKey:@"mk_lfx_refreshAnimation"];
    }else {
        self.refreshIcon.hidden = YES;
    }
    
    self.msgLabel.text = SafeStr(text);
    [self setNeedsLayout];
}

- (void)hidden {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - getter
- (UIImageView *)refreshIcon {
    if (!_refreshIcon) {
        _refreshIcon = [[UIImageView alloc] init];
        _refreshIcon.image = LOADICON(@"MokoLifeX", @"MKLFXEasyShowView", @"lfx_refreshIcon.png");
    }
    return _refreshIcon;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = COLOR_WHITE_MACROS;
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(18.f);
    }
    return _msgLabel;
}

@end
