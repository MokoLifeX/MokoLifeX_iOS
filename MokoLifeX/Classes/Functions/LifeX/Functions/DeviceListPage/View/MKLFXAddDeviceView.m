//
//  MKLFXAddDeviceView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAddDeviceView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@interface MKLFXAddDeviceView ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *centerIcon;

@end

@implementation MKLFXAddDeviceView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.centerIcon];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(52.f);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.centerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(268.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(268.f);
    }];
}

#pragma mark - setter & getter
- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = NAVBAR_COLOR_MACROS;
        _msgLabel.font = MKFont(18.f);
        _msgLabel.text = @"Start your moko lifeX";
    }
    return _msgLabel;
}

- (UIImageView *)centerIcon{
    if (!_centerIcon) {
        _centerIcon = [[UIImageView alloc] init];
        _centerIcon.image = LOADICON(@"MokoLifeX", @"MKLFXAddDeviceView", @"lfx_deviceList_centerIcon.png");
    }
    return _centerIcon;
}

@end
