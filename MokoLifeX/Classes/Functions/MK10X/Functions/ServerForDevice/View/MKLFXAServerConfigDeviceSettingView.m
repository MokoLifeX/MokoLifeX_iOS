//
//  MKLFXAServerConfigDeviceSettingView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAServerConfigDeviceSettingView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCustomUIAdopter.h"
#import "MKTextField.h"

@implementation MKLFXAServerConfigDeviceSettingViewModel
@end

@interface MKLFXAServerConfigDeviceSettingView ()

@property (nonatomic, strong)UIView *topLineView;

@property (nonatomic, strong)UILabel *topMsgLabel;

@property (nonatomic, strong)UILabel *deviceIDLabel;

@property (nonatomic, strong)MKTextField *deviceIDField;

@end

@implementation MKLFXAServerConfigDeviceSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topLineView];
        [self.topLineView addSubview:self.topMsgLabel];
        [self addSubview:self.deviceIDLabel];
        [self addSubview:self.deviceIDField];
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
    [self.deviceIDField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceIDLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.topLineView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.deviceIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(110.f);
        make.centerY.mas_equalTo(self.deviceIDField.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXAServerConfigDeviceSettingViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXAServerConfigDeviceSettingViewModel.class]) {
        return;
    }
    self.deviceIDField.text = SafeStr(_dataModel.deviceID);
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
        _topMsgLabel.text = @"Device Id";
    }
    return _topMsgLabel;
}

- (UILabel *)deviceIDLabel {
    if (!_deviceIDLabel) {
        _deviceIDLabel = [[UILabel alloc] init];
        _deviceIDLabel.textColor = DEFAULT_TEXT_COLOR;
        _deviceIDLabel.textAlignment = NSTextAlignmentLeft;
        _deviceIDLabel.font = MKFont(13.f);
        _deviceIDLabel.text = @"Device Id";
    }
    return _deviceIDLabel;
}

- (MKTextField *)deviceIDField {
    if (!_deviceIDField) {
        _deviceIDField = [[MKTextField alloc] initWithTextFieldType:mk_normal];
        @weakify(self);
        _deviceIDField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxa_mqtt_deviecSetting_deviceIDChanged:)]) {
                [self.delegate lfxa_mqtt_deviecSetting_deviceIDChanged:text];
            }
        };
        _deviceIDField.maxLength = 32;
        _deviceIDField.placeholder = @"1-32 Characters";
        _deviceIDField.borderStyle = UITextBorderStyleNone;
        _deviceIDField.font = MKFont(13.f);
        
        _deviceIDField.backgroundColor = COLOR_WHITE_MACROS;
        _deviceIDField.layer.masksToBounds = YES;
        _deviceIDField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _deviceIDField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _deviceIDField.layer.cornerRadius = 6.f;
    }
    return _deviceIDField;
}

@end
