//
//  MKLFXCDServerConfigDeviceSettingView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDServerConfigDeviceSettingView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCustomUIAdopter.h"
#import "MKPickerView.h"
#import "MKTextField.h"

@implementation MKLFXCDServerConfigDeviceSettingViewModel
@end

@interface MKLFXCDServerConfigDeviceSettingView ()

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

@property (nonatomic, strong)UIView *domainLine;

@property (nonatomic, strong)UILabel *domainMsgLabel;

@property (nonatomic, strong)UILabel *domainLabel;

@property (nonatomic, strong)UIButton *domainButton;

@property (nonatomic, strong)UILabel *domainNoteLabel;

@property (nonatomic, strong)NSArray *timeZoneList;

@property (nonatomic, strong)NSArray *domainList;

@end

@implementation MKLFXCDServerConfigDeviceSettingView

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
        [self addSubview:self.domainLine];
        [self.domainLine addSubview:self.domainMsgLabel];
        [self addSubview:self.domainLabel];
        [self addSubview:self.domainButton];
        [self addSubview:self.domainNoteLabel];
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
    [self.domainLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.noteLabel.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(20.f);
    }];
    [self.domainMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.domainLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.domainButton.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.domainButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.domainLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.domainLine.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(35.f);
    }];
    CGSize domainSize = [NSString sizeWithText:self.domainNoteLabel.text
                                       andFont:self.domainNoteLabel.font
                                    andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f, MAXFLOAT)];
    [self.domainNoteLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.domainButton.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(domainSize.height);
    }];
}

#pragma mark - event method
- (void)timeZoneButtonPressed {
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.timeZoneList.count; i ++) {
        if ([self.timeZoneButton.titleLabel.text isEqualToString:self.timeZoneList[i]]) {
            index = i;
            break;
        }
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    [pickView showPickViewWithDataList:self.timeZoneList selectedRow:index block:^(NSInteger currentRow) {
        [self.timeZoneButton setTitle:self.timeZoneList[currentRow] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_117D_timeZoneChanged:)]) {
            [self.delegate lfxc_mqtt_deviecSetting_117D_timeZoneChanged:currentRow];
        }
    }];
}

- (void)domainButtonPressed {
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.domainList.count; i ++) {
        if ([self.domainButton.titleLabel.text isEqualToString:self.domainList[i]]) {
            index = i;
            break;
        }
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    [pickView showPickViewWithDataList:self.domainList selectedRow:index block:^(NSInteger currentRow) {
        [self.domainButton setTitle:self.domainList[currentRow] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_117D_domainChanged:)]) {
            [self.delegate lfxc_mqtt_deviecSetting_117D_domainChanged:currentRow];
        }
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCDServerConfigDeviceSettingViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCDServerConfigDeviceSettingViewModel.class]) {
        return;
    }
    self.deviceIDField.text = SafeStr(_dataModel.deviceID);
    self.ntpUrlField.text = SafeStr(_dataModel.ntpHost);
    if (_dataModel.timeZone < 0 || dataModel.timeZone > 52) {
        return;
    }
    [self.timeZoneButton setTitle:self.timeZoneList[_dataModel.timeZone] forState:UIControlStateNormal];
    if (_dataModel.domain < 0 || _dataModel.domain > 21) {
        return;
    }
    [self.domainButton setTitle:self.domainList[_dataModel.domain] forState:UIControlStateNormal];
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
            if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_117D_deviceIDChanged:)]) {
                [self.delegate lfxc_mqtt_deviecSetting_117D_deviceIDChanged:text];
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
            if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_deviecSetting_117D_ntpURLChanged:)]) {
                [self.delegate lfxc_mqtt_deviecSetting_117D_ntpURLChanged:text];
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

- (UIView *)domainLine {
    if (!_domainLine) {
        _domainLine = [[UIView alloc] init];
        _domainLine.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    return _domainLine;
}

- (UILabel *)domainMsgLabel {
    if (!_domainMsgLabel) {
        _domainMsgLabel = [[UILabel alloc] init];
        _domainMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _domainMsgLabel.textAlignment = NSTextAlignmentLeft;
        _domainMsgLabel.font = MKFont(13.f);
        _domainMsgLabel.text = @"Channel & Domain";
    }
    return _domainMsgLabel;
}

- (UILabel *)domainLabel {
    if (!_domainLabel) {
        _domainLabel = [[UILabel alloc] init];
        _domainLabel.textColor = DEFAULT_TEXT_COLOR;
        _domainLabel.textAlignment = NSTextAlignmentLeft;
        _domainLabel.font = MKFont(13.f);
        _domainLabel.text = @"Domain";
    }
    return _domainLabel;
}

- (UIButton *)domainButton {
    if (!_domainButton) {
        _domainButton = [MKCustomUIAdopter customButtonWithTitle:@""
                                                          target:self
                                                          action:@selector(domainButtonPressed)];
        [_domainButton.titleLabel setFont:MKFont(13.f)];
    }
    return _domainButton;
}

- (UILabel *)domainNoteLabel {
    if (!_domainNoteLabel) {
        _domainNoteLabel = [[UILabel alloc] init];
        _domainNoteLabel.textColor = DEFAULT_TEXT_COLOR;
        _domainNoteLabel.textAlignment = NSTextAlignmentLeft;
        _domainNoteLabel.font = MKFont(13.f);
        _domainNoteLabel.text = @"Note: Configure 2.4G&5G channel by selecting your domain, channels will be matched according to the domain.";
        _domainNoteLabel.numberOfLines = 0;
    }
    return _domainNoteLabel;
}

- (NSArray *)timeZoneList {
    if (!_timeZoneList) {
        _timeZoneList = @[@"UTC-12:00",@"UTC-11:30",@"UTC-11:00",@"UTC-10:30",@"UTC-10:00",@"UTC-09:30",
                          @"UTC-09:00",@"UTC-08:30",@"UTC-08:00",@"UTC-07:30",@"UTC-07:00",@"UTC-06:30",
                          @"UTC-06:00",@"UTC-05:30",@"UTC-05:00",@"UTC-04:30",@"UTC-04:00",@"UTC-03:30",
                          @"UTC-03:00",@"UTC-02:30",@"UTC-02:00",@"UTC-01:30",@"UTC-01:00",@"UTC-00:30",
                          @"UTC+00:00",@"UTC+00:30",@"UTC+01:00",@"UTC+01:30",@"UTC+02:00",@"UTC+02:30",
                          @"UTC+03:00",@"UTC+03:30",@"UTC+04:00",@"UTC+04:30",@"UTC+05:00",@"UTC+05:30",
                          @"UTC+06:00",@"UTC+06:30",@"UTC+07:00",@"UTC+07:30",@"UTC+08:00",@"UTC+08:30",
                          @"UTC+09:00",@"UTC+09:30",@"UTC+10:00",@"UTC+10:30",@"UTC+11:00",@"UTC+11:30",
                          @"UTC+12:00",@"UTC+12:30",@"UTC+13:00",@"UTC+13:30",@"UTC+14:00"];
    }
    return _timeZoneList;
}

- (NSArray *)domainList {
    if (!_domainList) {
        _domainList = @[@"Argentina,Mexico",@"Australia,New Zealand",@"Bahrain,Egypt,Israel,India",
                        @"Bolivia,Chile,China,El Salvador",@"Canada",@"Europe",@"Indonesia",@"Japan",
        @"Jordan",@"Korea,US",@"Latin America-1",@"Latin America-2",@"Latin America-3",@"Lebanon",
        @"Malaysia",@"Qatar",@"Russia",@"Singapore",@"Taiwan",@"Tunisia",@"Venezuela",@"Worldwide"];
    }
    return _domainList;
}

@end
