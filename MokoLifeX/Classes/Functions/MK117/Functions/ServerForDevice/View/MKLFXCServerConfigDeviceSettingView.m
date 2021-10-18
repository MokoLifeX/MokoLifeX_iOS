//
//  MKLFXCServerConfigDeviceSettingView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCServerConfigDeviceSettingView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCustomUIAdopter.h"
#import "MKPickerView.h"
#import "MKTextField.h"

@implementation MKLFXCServerConfigDeviceSettingViewModel
@end

@interface MKLFXCServerConfigDeviceSettingView ()

@property (nonatomic, strong)UIView *topLineView;

@property (nonatomic, strong)UILabel *topMsgLabel;

@property (nonatomic, strong)UILabel *deviceIDLabel;

@property (nonatomic, strong)MKTextField *deviceIDField;

@property (nonatomic, strong)UIView *timeLineView;

@property (nonatomic, strong)UILabel *timeLineMsgLabel;

@property (nonatomic, strong)UILabel *ntpLabel;

@property (nonatomic, strong)MKTextField *ntpUrlField;

@property (nonatomic, strong)UILabel *timeZoneLabel;

@property (nonatomic, strong)UIButton *timeZoneButton;

@property (nonatomic, strong)UILabel *noteLabel;

@property (nonatomic, strong)NSArray *dataList;

@end

@implementation MKLFXCServerConfigDeviceSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.topLineView];
        [self.topLineView addSubview:self.topMsgLabel];
        [self addSubview:self.deviceIDLabel];
        [self addSubview:self.deviceIDField];
        [self addSubview:self.timeLineView];
        [self.timeLineView addSubview:self.timeLineMsgLabel];
        [self addSubview:self.ntpLabel];
        [self addSubview:self.ntpUrlField];
        [self addSubview:self.timeZoneLabel];
        [self addSubview:self.timeZoneButton];
        [self addSubview:self.noteLabel];
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
    [self.timeLineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.deviceIDField.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(20.f);
    }];
    [self.timeLineMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.ntpUrlField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.ntpLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.timeLineView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.ntpLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(110.f);
        make.centerY.mas_equalTo(self.ntpUrlField.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.timeZoneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(90.f);
        make.top.mas_equalTo(self.ntpUrlField.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.timeZoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.timeZoneButton.mas_left).mas_offset(-15.f);
        make.centerY.mas_equalTo(self.timeZoneButton.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    CGSize size = [NSString sizeWithText:self.noteLabel.text
                                 andFont:self.noteLabel.font
                              andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f, MAXFLOAT)];
    [self.noteLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.timeZoneButton.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(size.height);
    }];
}

#pragma mark - event method
- (void)timeZoneButtonPressed {
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        if ([self.timeZoneButton.titleLabel.text isEqualToString:self.dataList[i]]) {
            index = i;
            break;
        }
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    [pickView showPickViewWithDataList:self.dataList selectedRow:index block:^(NSInteger currentRow) {
        [self.timeZoneButton setTitle:self.dataList[currentRow] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_timeZoneChanged:)]) {
            [self.delegate lfxc_mqtt_deviecSetting_timeZoneChanged:currentRow];
        }
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCServerConfigDeviceSettingViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCServerConfigDeviceSettingViewModel.class]) {
        return;
    }
    self.deviceIDField.text = SafeStr(_dataModel.deviceID);
    self.ntpUrlField.text = SafeStr(_dataModel.ntpHost);
    if (_dataModel.timeZone < -24 || dataModel.timeZone > 24) {
        return;
    }
    [self.timeZoneButton setTitle:self.dataList[_dataModel.timeZone + 24] forState:UIControlStateNormal];
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
            if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_deviceIDChanged:)]) {
                [self.delegate lfxc_mqtt_deviecSetting_deviceIDChanged:text];
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

- (UIView *)timeLineView {
    if (!_timeLineView) {
        _timeLineView = [[UIView alloc] init];
        _timeLineView.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    return _timeLineView;
}

- (UILabel *)timeLineMsgLabel {
    if (!_timeLineMsgLabel) {
        _timeLineMsgLabel = [[UILabel alloc] init];
        _timeLineMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _timeLineMsgLabel.textAlignment = NSTextAlignmentLeft;
        _timeLineMsgLabel.font = MKFont(15.f);
        _timeLineMsgLabel.text = @"Time Setting";
    }
    return _timeLineMsgLabel;
}

- (UILabel *)ntpLabel {
    if (!_ntpLabel) {
        _ntpLabel = [[UILabel alloc] init];
        _ntpLabel.textColor = DEFAULT_TEXT_COLOR;
        _ntpLabel.textAlignment = NSTextAlignmentLeft;
        _ntpLabel.font = MKFont(13.f);
        _ntpLabel.text = @"NTP URL";
    }
    return _ntpLabel;
}

- (MKTextField *)ntpUrlField {
    if (!_ntpUrlField) {
        _ntpUrlField = [[MKTextField alloc] initWithTextFieldType:mk_normal];
        @weakify(self);
        _ntpUrlField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_ntpURLChanged:)]) {
                [self.delegate lfxc_mqtt_deviecSetting_ntpURLChanged:text];
            }
        };
        _ntpUrlField.maxLength = 64;
        _ntpUrlField.placeholder = @"0-64 Characters";
        _ntpUrlField.borderStyle = UITextBorderStyleNone;
        _ntpUrlField.font = MKFont(13.f);
        
        _ntpUrlField.backgroundColor = COLOR_WHITE_MACROS;
        _ntpUrlField.layer.masksToBounds = YES;
        _ntpUrlField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _ntpUrlField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _ntpUrlField.layer.cornerRadius = 6.f;
    }
    return _ntpUrlField;
}

- (UILabel *)timeZoneLabel {
    if (!_timeZoneLabel) {
        _timeZoneLabel = [[UILabel alloc] init];
        _timeZoneLabel.textColor = DEFAULT_TEXT_COLOR;
        _timeZoneLabel.textAlignment = NSTextAlignmentLeft;
        _timeZoneLabel.font = MKFont(13.f);
        _timeZoneLabel.text = @"TimeZone";
    }
    return _timeZoneLabel;
}

- (UIButton *)timeZoneButton {
    if (!_timeZoneButton) {
        _timeZoneButton = [MKCustomUIAdopter customButtonWithTitle:@"UTC+00:00"
                                                            target:self
                                                            action:@selector(timeZoneButtonPressed)];
        [_timeZoneButton.titleLabel setFont:MKFont(13.f)];
    }
    return _timeZoneButton;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.textColor = DEFAULT_TEXT_COLOR;
        _noteLabel.textAlignment = NSTextAlignmentLeft;
        _noteLabel.font = MKFont(13.f);
        _noteLabel.text = @"Note: the NTP URL can be set to empty, then it will use the default NTP server";
        _noteLabel.numberOfLines = 0;
    }
    return _noteLabel;
}

- (NSArray *)dataList {
    if (!_dataList) {
        _dataList = @[@"UTC-12:00",@"UTC-11:30",@"UTC-11:00",@"UTC-10:30",@"UTC-10:00",@"UTC-09:30",
                      @"UTC-09:00",@"UTC-08:30",@"UTC-08:00",@"UTC-07:30",@"UTC-07:00",@"UTC-06:30",
                      @"UTC-06:00",@"UTC-05:30",@"UTC-05:00",@"UTC-04:30",@"UTC-04:00",@"UTC-03:30",
                      @"UTC-03:00",@"UTC-02:30",@"UTC-02:00",@"UTC-01:30",@"UTC-01:00",@"UTC-00:30",
                      @"UTC+00:00",@"UTC+00:30",@"UTC+01:00",@"UTC+01:30",@"UTC+02:00",@"UTC+02:30",
                      @"UTC+03:00",@"UTC+03:30",@"UTC+04:00",@"UTC+04:30",@"UTC+05:00",@"UTC+05:30",
                      @"UTC+06:00",@"UTC+06:30",@"UTC+07:00",@"UTC+07:30",@"UTC+08:00",@"UTC+08:30",
                      @"UTC+09:00",@"UTC+09:30",@"UTC+10:00",@"UTC+10:30",@"UTC+11:00",@"UTC+11:30",
                      @"UTC+12:00"];
    }
    return _dataList;
}

@end
