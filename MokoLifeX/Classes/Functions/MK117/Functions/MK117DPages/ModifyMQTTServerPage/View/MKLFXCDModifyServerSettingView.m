//
//  MKLFXCDModifyServerSettingView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDModifyServerSettingView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKTextField.h"

@implementation MKLFXCDModifyServerSettingViewModel
@end

@interface MKLFXCDModifyServerSettingView ()

@property (nonatomic, strong)UIView *topLineView;

@property (nonatomic, strong)UILabel *topMsgLabel;

@property (nonatomic, strong)UILabel *ssidLabel;

@property (nonatomic, strong)MKTextField *ssidField;

@property (nonatomic, strong)UILabel *passwordLabel;

@property (nonatomic, strong)MKTextField *passwordField;

@end

@implementation MKLFXCDModifyServerSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topLineView];
        [self.topLineView addSubview:self.topMsgLabel];
        [self addSubview:self.ssidLabel];
        [self addSubview:self.ssidField];
        [self addSubview:self.passwordLabel];
        [self addSubview:self.passwordField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.topLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(20.f);
    }];
    [self.topMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.ssidField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.ssidLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.topLineView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.ssidLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(110.f);
        make.centerY.mas_equalTo(self.ssidField.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.passwordField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.passwordLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.ssidField.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.passwordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(110.f);
        make.centerY.mas_equalTo(self.passwordField.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCDModifyServerSettingViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCDModifyServerSettingViewModel.class]) {
        return;
    }
    self.ssidField.text = SafeStr(_dataModel.ssid);
    self.passwordField.text = SafeStr(_dataModel.password);
}

#pragma mark - getter
- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    return _topLineView;
}

- (UILabel *)topMsgLabel {
    if (!_topMsgLabel) {
        _topMsgLabel = [[UILabel alloc] init];
        _topMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _topMsgLabel.textAlignment = NSTextAlignmentLeft;
        _topMsgLabel.font = MKFont(15.f);
        _topMsgLabel.text = @"WIFI";
    }
    return _topMsgLabel;
}

- (UILabel *)ssidLabel {
    if (!_ssidLabel) {
        _ssidLabel = [[UILabel alloc] init];
        _ssidLabel.textColor = DEFAULT_TEXT_COLOR;
        _ssidLabel.textAlignment = NSTextAlignmentLeft;
        _ssidLabel.font = MKFont(13.f);
        _ssidLabel.text = @"SSID";
    }
    return _ssidLabel;
}

- (MKTextField *)ssidField {
    if (!_ssidField) {
        _ssidField = [[MKTextField alloc] initWithTextFieldType:mk_normal];
        @weakify(self);
        _ssidField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxc_117d_mqtt_modifyDevice_wifiSSIDChanged:)]) {
                [self.delegate lfxc_117d_mqtt_modifyDevice_wifiSSIDChanged:text];
            }
        };
        _ssidField.maxLength = 32;
        _ssidField.placeholder = @"1-32 Characters";
        _ssidField.borderStyle = UITextBorderStyleNone;
        _ssidField.font = MKFont(13.f);
        
        _ssidField.backgroundColor = COLOR_WHITE_MACROS;
        _ssidField.layer.masksToBounds = YES;
        _ssidField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _ssidField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _ssidField.layer.cornerRadius = 6.f;
    }
    return _ssidField;
}

- (UILabel *)passwordLabel {
    if (!_passwordLabel) {
        _passwordLabel = [[UILabel alloc] init];
        _passwordLabel.textColor = DEFAULT_TEXT_COLOR;
        _passwordLabel.textAlignment = NSTextAlignmentLeft;
        _passwordLabel.font = MKFont(13.f);
        _passwordLabel.text = @"Password";
    }
    return _passwordLabel;
}

- (MKTextField *)passwordField {
    if (!_passwordField) {
        _passwordField = [[MKTextField alloc] initWithTextFieldType:mk_normal];
        @weakify(self);
        _passwordField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxc_117d_mqtt_modifyDevice_wifiPasswordChanged:)]) {
                [self.delegate lfxc_117d_mqtt_modifyDevice_wifiPasswordChanged:text];
            }
        };
        _passwordField.maxLength = 64;
        _passwordField.placeholder = @"0-64 Characters";
        _passwordField.borderStyle = UITextBorderStyleNone;
        _passwordField.font = MKFont(13.f);
        
        _passwordField.backgroundColor = COLOR_WHITE_MACROS;
        _passwordField.layer.masksToBounds = YES;
        _passwordField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _passwordField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _passwordField.layer.cornerRadius = 6.f;
    }
    return _passwordField;
}

@end
