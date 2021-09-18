//
//  MKLFXCConnectionController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCConnectionController.h"

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
#import "MKLFXCMQTTManager.h"

@interface MKLFXCConnectionController ()

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UILabel *noteLabel;

@end

@implementation MKLFXCConnectionController

- (void)dealloc {
    NSLog(@"MKLFXCConnectionController销毁");
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
                                             selector:@selector(receiveConnectionTimeoutSetting:)
                                                 name:MKLFXCReceiveConnectionTimeoutSettingNotification
                                               object:nil];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self confirmButtonPressed];
}

#pragma mark - note
- (void)receiveConnectionTimeoutSetting:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1121) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    self.textField.text = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"timeout"]];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    if (!ValidStr(self.textField.text) || [self.textField.text integerValue] < 0 || [self.textField.text integerValue] > 1440) {
        [self.view showCentralToast:@"Params error"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configConnectionTimeout:[self.textField.text integerValue]
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
    [MKLFXCMQTTInterface lfxc_readConnectionTimeoutWithDeviceID:self.deviceModel.deviceID
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
    self.defaultTitle = @"Connection Timeout Setting";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCConnectionController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
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
    
    UILabel *bottomMsgLabel = [[UILabel alloc] init];
    bottomMsgLabel.textColor = RGBCOLOR(207, 207, 207);
    bottomMsgLabel.textAlignment = NSTextAlignmentLeft;
    bottomMsgLabel.font = MKFont(12.f);
    bottomMsgLabel.numberOfLines = 0;
    bottomMsgLabel.text = @"If the connection time exceeds the set value, device will reboot automatically. Value 0 means no reboot.";
    [self.view addSubview:bottomMsgLabel];
    
    CGSize bottomMsgSize = [NSString sizeWithText:bottomMsgLabel.text
                                          andFont:bottomMsgLabel.font
                                       andMaxSize:CGSizeMake(kViewWidth - 2 * 15.f, MAXFLOAT)];
    [bottomMsgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.noteLabel.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(bottomMsgSize.height);
    }];
}

#pragma mark - getter
- (MKTextField *)textField {
    if (!_textField) {
        _textField = [[MKTextField alloc] initWithTextFieldType:mk_realNumberOnly];
        _textField.maxLength = 4;
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
        _noteLabel.text = @"Range: 0-1440，unit: min";
    }
    return _noteLabel;
}

@end
