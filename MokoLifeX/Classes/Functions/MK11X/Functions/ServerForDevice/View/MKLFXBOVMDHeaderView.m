//
//  MKLFXBOVMDHeaderView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBOVMDHeaderView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKTextField.h"
#import "MKPickerView.h"

#import "MKLFXBOVMDHeaderViewModel.h"

static CGFloat const offset_X = 15.f;
static CGFloat const offset_Y = 10.f;
static CGFloat const msgLabelWidth = 100.f;
static CGFloat const textFieldHeight = 35.f;

@interface MKLFXBOVMDHeaderConnectModeButton : UIControl

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *msgLabel;

@end

@implementation MKLFXBOVMDHeaderConnectModeButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.icon];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(13.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(13.f);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.icon.mas_right);
        make.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(13.f);
    }
    return _msgLabel;
}

@end

@interface MKLFXBOVMDHeaderQosButton : UIControl

@property (nonatomic, strong)UIImageView *icon;

@property (nonatomic, strong)UILabel *msgLabel;

@end

@implementation MKLFXBOVMDHeaderQosButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.icon];
        [self addSubview:self.msgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5.f);
        make.width.mas_equalTo(9.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(8);
    }];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.f);
        make.right.mas_equalTo(self.icon.mas_left).mas_offset(-1.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderQosButton", @"lfx_triangleIcon.png");
    }
    return _icon;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"1";
    }
    return _msgLabel;
}

@end

@interface MKLFXBOVMDHeaderView ()

@property (nonatomic, strong)UILabel *hostLabel;

@property (nonatomic, strong)MKTextField *hostTextField;

@property (nonatomic, strong)UILabel *portLabel;

@property (nonatomic, strong)MKTextField *portTextField;

@property (nonatomic, strong)UILabel *cleanSessionLabel;

@property (nonatomic, strong)UIButton *cleanSessionButton;

@property (nonatomic, strong)UILabel *userNameLabel;

@property (nonatomic, strong)MKTextField *userNameTextField;

@property (nonatomic, strong)UILabel *passwordLabel;

@property (nonatomic, strong)MKTextField *passwordTextField;

@property (nonatomic, strong)UILabel *qosLabel;

@property (nonatomic, strong)MKLFXBOVMDHeaderQosButton *qosButton;

@property (nonatomic, strong)UILabel *keepAliveLabel;

@property (nonatomic, strong)MKTextField *keepAliveTextField;

@property (nonatomic, strong)UILabel *cliendIDLabel;

@property (nonatomic, strong)MKTextField *clientIDTextField;

@property (nonatomic, strong)UILabel *deviceIDLabel;

@property (nonatomic, strong)MKTextField *deviceIDTextField;

@property (nonatomic, strong)UILabel *connectModeLabel;

@property (nonatomic, strong)MKLFXBOVMDHeaderConnectModeButton *tcpButton;

@property (nonatomic, strong)MKLFXBOVMDHeaderConnectModeButton *oneWayButton;

@property (nonatomic, strong)MKLFXBOVMDHeaderConnectModeButton *twoWayButton;

@property (nonatomic, assign)NSInteger connectMode;

@end

@implementation MKLFXBOVMDHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RGBCOLOR(242, 242, 242);
        [self addSubview:self.hostLabel];
        [self addSubview:self.hostTextField];
        [self addSubview:self.portLabel];
        [self addSubview:self.portTextField];
        [self addSubview:self.cleanSessionLabel];
        [self addSubview:self.cleanSessionButton];
        [self addSubview:self.userNameLabel];
        [self addSubview:self.userNameTextField];
        [self addSubview:self.passwordLabel];
        [self addSubview:self.passwordTextField];
        [self addSubview:self.qosLabel];
        [self addSubview:self.qosButton];
        [self addSubview:self.keepAliveLabel];
        [self addSubview:self.keepAliveTextField];
        [self addSubview:self.cliendIDLabel];
        [self addSubview:self.clientIDTextField];
        [self addSubview:self.deviceIDLabel];
        [self addSubview:self.deviceIDTextField];
        [self addSubview:self.connectModeLabel];
        [self addSubview:self.tcpButton];
        [self addSubview:self.oneWayButton];
        [self addSubview:self.twoWayButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.hostLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.hostTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.hostTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.hostLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(20.f);
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [self.portLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.portTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.portTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.portLabel.mas_right).mas_offset(10.f);
        make.width.mas_equalTo(60.f);
        make.top.mas_equalTo(self.hostTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.cleanSessionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.portTextField.mas_right).mas_offset(20.f);
        make.width.mas_equalTo(120.f);
        make.centerY.mas_equalTo(self.portTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.cleanSessionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.portTextField.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    
    [self.userNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.userNameTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.userNameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userNameLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.portTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [self.passwordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.passwordTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.passwordTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.passwordLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.userNameTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [self.keepAliveTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(70.f);
        make.top.mas_equalTo(self.passwordTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.keepAliveLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.keepAliveTextField.mas_left).mas_offset(-5.f);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.keepAliveTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.qosLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.keepAliveTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.qosButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.qosLabel.mas_right).mas_offset(1.f);
        make.right.mas_equalTo(self.keepAliveLabel.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.keepAliveTextField.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    
    [self.cliendIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.clientIDTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.clientIDTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cliendIDLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.keepAliveTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [self.deviceIDLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.deviceIDTextField.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.deviceIDTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceIDLabel.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.clientIDTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    [self.connectModeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.right.mas_equalTo(-offset_X);
        make.top.mas_equalTo(self.deviceIDTextField.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    
    CGFloat width = (self.frame.size.width - 4 * offset_X) / 3;
    [self.tcpButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(offset_X);
        make.width.mas_equalTo(width);
        make.top.mas_equalTo(self.connectModeLabel.mas_bottom).mas_offset(offset_Y);
        make.height.mas_equalTo(30.f);
    }];
    [self.oneWayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(width);
        make.centerY.mas_equalTo(self.tcpButton.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.twoWayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-offset_X);
        make.width.mas_equalTo(width);
        make.centerY.mas_equalTo(self.tcpButton.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - event method
- (void)cleanSessionButtonPressed {
    self.cleanSessionButton.selected = !self.cleanSessionButton.selected;
    UIImage *cleanIcon = (self.cleanSessionButton.selected ? LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_switchSelectedIcon.png") : LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_switchUnselectedIcon.png"));
    [self.cleanSessionButton setImage:cleanIcon forState:UIControlStateNormal];
    [self resignAllTextField];
    if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewCleanSessionChanged:)]) {
        [self.delegate lfxb_ovmdHeaderViewCleanSessionChanged:self.cleanSessionButton.selected];
    }
}

- (void)qosButtonPressed {
    [self resignAllTextField];
    NSArray *dataList = @[@"0",@"1",@"2"];
    NSInteger index = 0;
    for (NSInteger i = 0; i < dataList.count; i ++) {
        if ([self.qosButton.msgLabel.text isEqualToString:dataList[i]]) {
            index = i;
            break;
        }
    }

    MKPickerView *pickView = [[MKPickerView alloc] init];
    [pickView showPickViewWithDataList:dataList selectedRow:index block:^(NSInteger currentRow) {
        self.qosButton.msgLabel.text = dataList[currentRow];
        if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewQosChanged:)]) {
            [self.delegate lfxb_ovmdHeaderViewQosChanged:currentRow];
        }
    }];
}

- (void)tcpButtonPressed {
    [self resignAllTextField];
    if (self.connectMode == 0) {
        return;
    }
    self.connectMode = 0;
    [self updateConnectMode];
    if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewConnectModeChanged:)]) {
        [self.delegate lfxb_ovmdHeaderViewConnectModeChanged:0];
    }
}

- (void)oneWayButtonPressed {
    [self resignAllTextField];
    if (self.connectMode == 1) {
        return;
    }
    self.connectMode = 1;
    [self updateConnectMode];
    if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewConnectModeChanged:)]) {
        [self.delegate lfxb_ovmdHeaderViewConnectModeChanged:1];
    }
}

- (void)twoWayButtonPressed {
    [self resignAllTextField];
    if (self.connectMode == 2) {
        return;
    }
    self.connectMode = 2;
    [self updateConnectMode];
    if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewConnectModeChanged:)]) {
        [self.delegate lfxb_ovmdHeaderViewConnectModeChanged:2];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKLFXBOVMDHeaderViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXBOVMDHeaderViewModel.class]) {
        return;
    }
    self.hostTextField.text = SafeStr(_dataModel.host);
    self.portTextField.text = SafeStr(_dataModel.port);
    self.cleanSessionButton.selected = _dataModel.cleanSession;
    UIImage *cleanIcon = (_dataModel.cleanSession ? LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_switchSelectedIcon.png") : LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_switchUnselectedIcon.png"));
    [self.cleanSessionButton setImage:cleanIcon forState:UIControlStateNormal];
    self.userNameTextField.text = SafeStr(_dataModel.userName);
    self.passwordTextField.text = SafeStr(_dataModel.password);
    self.qosButton.msgLabel.text = [NSString stringWithFormat:@"%ld",(long)_dataModel.qos];
    self.keepAliveTextField.text = SafeStr(_dataModel.keepAlive);
    self.clientIDTextField.text = SafeStr(_dataModel.clientID);
    self.deviceIDTextField.text = SafeStr(_dataModel.deviceID);
    self.connectMode = _dataModel.connectMode;
    [self updateConnectMode];
}

#pragma mark - private method
- (void)updateConnectMode {
    if (self.connectMode == 0) {
        //tcp
        self.tcpButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeSelectedIcon.png");
        self.oneWayButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeUnselectedIcon.png");
        self.twoWayButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeUnselectedIcon.png");
        return;
    }
    if (self.connectMode == 1) {
        //one-way SSL
        self.tcpButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeUnselectedIcon.png");
        self.oneWayButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeSelectedIcon.png");
        self.twoWayButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeUnselectedIcon.png");
        return;
    }
    if (self.connectMode == 2) {
        //two-way SSL
        self.tcpButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeUnselectedIcon.png");
        self.oneWayButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeUnselectedIcon.png");
        self.twoWayButton.icon.image = LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_connectModeSelectedIcon.png");
        return;
    }
}

- (void)resignAllTextField {
    [self.hostTextField resignFirstResponder];
    [self.portTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.keepAliveTextField resignFirstResponder];
    [self.clientIDTextField resignFirstResponder];
    [self.deviceIDTextField resignFirstResponder];
}

#pragma mark - getter
- (UILabel *)hostLabel {
    if (!_hostLabel) {
        _hostLabel = [self loadLabelWithMsg:@"Host"];
    }
    return _hostLabel;
}

- (MKTextField *)hostTextField {
    if (!_hostTextField) {
        _hostTextField = [self loadTextWithPlaceHolder:@"1-64 Characters"
                                              textType:mk_normal
                                                maxLen:64];
        @weakify(self);
        _hostTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:0];
            }
        };
    }
    return _hostTextField;
}

- (UILabel *)portLabel {
    if (!_portLabel) {
        _portLabel = [self loadLabelWithMsg:@"Port"];
    }
    return _portLabel;
}

- (MKTextField *)portTextField {
    if (!_portTextField) {
        _portTextField = [self loadTextWithPlaceHolder:@"0-65535"
                                              textType:mk_realNumberOnly
                                                maxLen:5];
        @weakify(self);
        _portTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:1];
            }
        };
    }
    return _portTextField;
}

- (UILabel *)cleanSessionLabel {
    if (!_cleanSessionLabel) {
        _cleanSessionLabel = [self loadLabelWithMsg:@"Clean Session"];
    }
    return _cleanSessionLabel;
}

- (UIButton *)cleanSessionButton {
    if (!_cleanSessionButton) {
        _cleanSessionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanSessionButton setImage:LOADICON(@"MokoLifeX", @"MKLFXBOVMDHeaderView", @"lfx_switchSelectedIcon.png") forState:UIControlStateNormal];
        [_cleanSessionButton addTarget:self
                                action:@selector(cleanSessionButtonPressed)
                      forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanSessionButton;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [self loadLabelWithMsg:@"Username"];
    }
    return _userNameLabel;
}

- (MKTextField *)userNameTextField {
    if (!_userNameTextField) {
        _userNameTextField = [self loadTextWithPlaceHolder:@"0-256 Characters"
                                                  textType:mk_normal
                                                    maxLen:256];
        @weakify(self);
        _userNameTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:2];
            }
        };
    }
    return _userNameTextField;
}

- (UILabel *)passwordLabel {
    if (!_passwordLabel) {
        _passwordLabel = [self loadLabelWithMsg:@"Password"];
    }
    return _passwordLabel;
}

- (MKTextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [self loadTextWithPlaceHolder:@"0-256 Characters"
                                                  textType:mk_normal
                                                    maxLen:256];
        @weakify(self);
        _passwordTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:3];
            }
        };
    }
    return _passwordTextField;
}

- (UILabel *)qosLabel {
    if (!_qosLabel) {
        _qosLabel = [self loadLabelWithMsg:@"Qos"];
    }
    return _qosLabel;
}

- (MKLFXBOVMDHeaderQosButton *)qosButton {
    if (!_qosButton) {
        _qosButton = [[MKLFXBOVMDHeaderQosButton alloc] init];
        _qosButton.backgroundColor = COLOR_WHITE_MACROS;
        [_qosButton addTarget:self
                       action:@selector(qosButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _qosButton;
}

- (UILabel *)keepAliveLabel {
    if (!_keepAliveLabel) {
        _keepAliveLabel = [self loadLabelWithMsg:@"Keep Alive"];
    }
    return _keepAliveLabel;
}

- (MKTextField *)keepAliveTextField {
    if (!_keepAliveTextField) {
        _keepAliveTextField = [self loadTextWithPlaceHolder:@"10-120"
                                                   textType:mk_realNumberOnly
                                                     maxLen:3];
        @weakify(self);
        _keepAliveTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:4];
            }
        };
    }
    return _keepAliveTextField;
}

- (UILabel *)cliendIDLabel {
    if (!_cliendIDLabel) {
        _cliendIDLabel = [self loadLabelWithMsg:@"Client Id"];
    }
    return _cliendIDLabel;
}

- (MKTextField *)clientIDTextField {
    if (!_clientIDTextField) {
        _clientIDTextField = [self loadTextWithPlaceHolder:@"1-64 Characters"
                                                  textType:mk_normal
                                                    maxLen:64];
        @weakify(self);
        _clientIDTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:5];
            }
        };
    }
    return _clientIDTextField;
}

- (UILabel *)deviceIDLabel {
    if (!_deviceIDLabel) {
        _deviceIDLabel = [self loadLabelWithMsg:@"Device Id"];
    }
    return _deviceIDLabel;
}

- (MKTextField *)deviceIDTextField {
    if (!_deviceIDTextField) {
        _deviceIDTextField = [self loadTextWithPlaceHolder:@"1-64 Characters"
                                                  textType:mk_normal
                                                    maxLen:64];
        @weakify(self);
        _deviceIDTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxb_ovmdHeaderViewTextFieldValueChanged:index:)]) {
                [self.delegate lfxb_ovmdHeaderViewTextFieldValueChanged:text index:6];
            }
        };
    }
    return _deviceIDTextField;
}

- (UILabel *)connectModeLabel {
    if (!_connectModeLabel) {
        _connectModeLabel = [self loadLabelWithMsg:@"Connect Mode"];
    }
    return _connectModeLabel;
}

- (MKLFXBOVMDHeaderConnectModeButton *)tcpButton {
    if (!_tcpButton) {
        _tcpButton = [[MKLFXBOVMDHeaderConnectModeButton alloc] init];
        _tcpButton.msgLabel.text = @"TCP";
        [_tcpButton addTarget:self
                       action:@selector(tcpButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _tcpButton;
}

- (MKLFXBOVMDHeaderConnectModeButton *)oneWayButton {
    if (!_oneWayButton) {
        _oneWayButton = [[MKLFXBOVMDHeaderConnectModeButton alloc] init];
        _oneWayButton.msgLabel.text = @"One-way SSL";
        [_oneWayButton addTarget:self
                          action:@selector(oneWayButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _oneWayButton;
}

- (MKLFXBOVMDHeaderConnectModeButton *)twoWayButton {
    if (!_twoWayButton) {
        _twoWayButton = [[MKLFXBOVMDHeaderConnectModeButton alloc] init];
        [_twoWayButton addTarget:self
                          action:@selector(twoWayButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
        _twoWayButton.msgLabel.text = @"Two-way SSL";
    }
    return _twoWayButton;
}

- (MKTextField *)loadTextWithPlaceHolder:(NSString *)placeHolder
                                textType:(mk_textFieldType)textType
                                  maxLen:(NSInteger)maxLen {
    MKTextField *textField = [[MKTextField alloc] init];
    textField.textType = textType;
    textField.borderStyle = UITextBorderStyleNone;
    textField.maxLength = maxLen;
    textField.placeholder = placeHolder;
    textField.font = MKFont(13.f);
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
    textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
    textField.layer.cornerRadius = 6.f;
    return textField;
}

- (UILabel *)loadLabelWithMsg:(NSString *)msg {
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.textColor = DEFAULT_TEXT_COLOR;
    tempLabel.textAlignment = NSTextAlignmentLeft;
    tempLabel.font = MKFont(15.f);
    tempLabel.text = msg;
    return tempLabel;
}

@end
