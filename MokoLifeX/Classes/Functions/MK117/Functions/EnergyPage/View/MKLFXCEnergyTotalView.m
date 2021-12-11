//
//  MKLFXCEnergyTotalView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/13.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCEnergyTotalView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@interface MKLFXCEnergyTotalView ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *totalMsgLabel;

@property (nonatomic, strong)UILabel *energyValueLabel;

@property (nonatomic, strong)UILabel *unitLabel;

@end

@implementation MKLFXCEnergyTotalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.totalMsgLabel];
        [self addSubview:self.energyValueLabel];
        [self addSubview:self.unitLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(24.f);
        make.right.mas_equalTo(-24.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(18.f).lineHeight);
    }];
    [self.energyValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(150.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(40.f);
        make.height.mas_equalTo(MKFont(30.f).lineHeight);
    }];
    [self.totalMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.energyValueLabel.mas_left).mas_offset(-10.f);
        make.width.mas_equalTo(40.f);
        make.bottom.mas_equalTo(self.energyValueLabel.mas_bottom);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.unitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.energyValueLabel.mas_right).mas_offset(10.f);
        make.width.mas_equalTo(40.f);
        make.bottom.mas_equalTo(self.energyValueLabel.mas_bottom);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
}

#pragma mark - public method
- (void)updateTotalValue:(NSString *)totalValue {
    self.energyValueLabel.text = SafeStr(totalValue);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(18.f);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.text = @"Energy";
    }
    return _msgLabel;
}

- (UILabel *)totalMsgLabel {
    if (!_totalMsgLabel) {
        _totalMsgLabel = [[UILabel alloc] init];
        _totalMsgLabel.textColor = RGBCOLOR(128, 128, 128);
        _totalMsgLabel.textAlignment = NSTextAlignmentRight;
        _totalMsgLabel.font = MKFont(14.f);
        _totalMsgLabel.text = @"Total";
    }
    return _totalMsgLabel;
}

- (UILabel *)energyValueLabel {
    if (!_energyValueLabel) {
        _energyValueLabel = [[UILabel alloc] init];
        _energyValueLabel.textColor = UIColorFromRGB(0x0188cc);
        _energyValueLabel.font = MKFont(30.f);
        _energyValueLabel.textAlignment = NSTextAlignmentCenter;
        _energyValueLabel.text = @"0.0";
    }
    return _energyValueLabel;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textColor = RGBCOLOR(128, 128, 128);
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.font = MKFont(14.f);
        _unitLabel.text = @"KWh";
    }
    return _unitLabel;
}

@end
