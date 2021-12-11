//
//  MKLFXBSwitchViewButton.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/31.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBSwitchViewButton.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKLFXBSwitchViewButtonModel
@end

@interface MKLFXBSwitchViewButton ()

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *msgLabel;

@end

@implementation MKLFXBSwitchViewButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.icon];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize iconSize = self.icon.image.size;
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(iconSize.width);
        make.top.mas_equalTo(1.f);
        make.height.mas_equalTo(iconSize.height);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(1.f);
        make.right.mas_equalTo(-1.f);
        make.bottom.mas_equalTo(-1.f);
        make.height.mas_equalTo(MKFont(11.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXBSwitchViewButtonModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXBSwitchViewButtonModel.class]) {
        return;
    }
    self.icon.image = _dataModel.icon;
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.msgLabel.textColor = _dataModel.msgColor;
    [self setNeedsLayout];
}

#pragma mark - getter
- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(11.f);
        _msgLabel.textColor = UIColorFromRGB(0x808080);
    }
    return _msgLabel;
}

@end
