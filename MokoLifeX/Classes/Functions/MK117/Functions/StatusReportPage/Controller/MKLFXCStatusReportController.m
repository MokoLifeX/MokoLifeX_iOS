//
//  MKLFXCStatusReportController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCStatusReportController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "NSString+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextField.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"

@interface MKLFXCStatusReportController ()

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UILabel *noteLabel;

@end

@implementation MKLFXCStatusReportController

- (void)dealloc {
    NSLog(@"MKLFXCStatusReportController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self laodSubViews];
    [self readDataFromDevice];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSwitchStatusReportInterval:)
                                                 name:MKLFXCReceiveSwitchStatusReportIntervalNotification
                                               object:nil];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self confirmButtonPressed];
}

#pragma mark - note
- (void)receiveSwitchStatusReportInterval:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1101) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    self.textField.text = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"report_interval"]];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    if (!ValidStr(self.textField.text) || [self.textField.text integerValue] < 1 || [self.textField.text integerValue] > 600) {
        [self.view showCentralToast:@"Params error"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configSwitchStatusReportInterval:[self.textField.text integerValue]
                                                      deviceID:self.deviceModel.deviceID
                                                         topic:[self.deviceModel currentSubscribedTopic]
                                                      sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    }
                                                   failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_readSwitchStatusReportIntervalWithDeviceID:self.deviceModel.deviceID
                                                                   topic:[self.deviceModel currentSubscribedTopic]
                                                                sucBlock:^{
        [self startReadTimer];
    }
                                                             failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI
- (void)laodSubViews {
    self.defaultTitle = @"Device Status Report Period";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCStatusReportController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 10.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.view addSubview:self.noteLabel];
    CGSize noteSize = [NSString sizeWithText:self.noteLabel.text
                                     andFont:self.noteLabel.font
                                  andMaxSize:CGSizeMake(kViewWidth - 2 * 15.f, MAXFLOAT)];
    [self.noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.textField.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(noteSize.height);
    }];
}

#pragma mark - getter
- (MKTextField *)textField {
    if (!_textField) {
        _textField = [[MKTextField alloc] initWithTextFieldType:mk_realNumberOnly];
        _textField.maxLength = 3;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = MKFont(15.f);
        
        _textField.backgroundColor = COLOR_WHITE_MACROS;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.cornerRadius = 6.f;
    }
    return _textField;
}

- (UILabel *)noteLabel {
    if (!_noteLabel) {
        _noteLabel = [[UILabel alloc] init];
        _noteLabel.textColor = RGBCOLOR(207, 207, 207);
        _noteLabel.textAlignment = NSTextAlignmentCenter;
        _noteLabel.font = MKFont(13.f);
        _noteLabel.numberOfLines = 0;
        _noteLabel.text = @"Range: 1-600, unit: s";
    }
    return _noteLabel;
}

@end
