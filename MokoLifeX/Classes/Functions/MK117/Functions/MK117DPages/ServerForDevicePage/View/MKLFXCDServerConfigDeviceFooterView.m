//
//  MKLFXCDServerConfigDeviceFooterView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDServerConfigDeviceFooterView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKMQTTGeneralParamsView.h"
#import "MKMQTTUserCredentialsView.h"

#import "MKLFXCDMQTTSSLForDeviceView.h"
#import "MKLFXCDServerConfigDeviceSettingView.h"

@implementation MKLFXCDServerConfigDeviceFooterViewModel
@end

static CGFloat const buttonWidth = 100.f;
static CGFloat const buttonHeight = 30.f;
static CGFloat const settingViewHeight = 290.f;
static CGFloat const defaultScrollViewHeight = 270.f;

@interface MKLFXCDServerConfigDeviceFooterView ()<UIScrollViewDelegate,
MKMQTTGeneralParamsViewDelegate,
MKMQTTUserCredentialsViewDelegate,
MKLFXCDMQTTSSLForDeviceViewDelegate,
MKLFXCDServerConfigDeviceSettingViewDelegate>

@property (nonatomic, strong)UIView *topLineView;

@property (nonatomic, strong)UIButton *generalButton;

@property (nonatomic, strong)UIButton *credentialsButton;

@property (nonatomic, strong)UIButton *sslButton;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong)MKMQTTGeneralParamsView *generalView;

@property (nonatomic, strong)MKMQTTUserCredentialsView *credentialsView;

@property (nonatomic, strong)MKLFXCDMQTTSSLForDeviceView *sslView;

@property (nonatomic, strong)MKLFXCDServerConfigDeviceSettingView *settingView;

@property (nonatomic, assign)NSInteger index;

@end

@implementation MKLFXCDServerConfigDeviceFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadSubViews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(40.f);
    }];
    [self.generalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10.f);
        make.width.mas_equalTo(buttonWidth);
        make.centerY.mas_equalTo(self.topLineView.mas_centerY);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.credentialsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(buttonWidth);
        make.centerY.mas_equalTo(self.generalButton.mas_centerY);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.sslButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10.f);
        make.width.mas_equalTo(buttonWidth);
        make.centerY.mas_equalTo(self.generalButton.mas_centerY);
        make.height.mas_equalTo(buttonHeight);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.topLineView.mas_bottom).mas_offset(10.f);
        make.bottom.mas_equalTo(self.settingView.mas_top);
    }];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.height.mas_equalTo(self.scrollView);       //水平滚动高度固定
    }];
    [self.generalView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self.containerView);
        make.width.equalTo(self.scrollView);
        make.left.mas_equalTo(0);
    }];
    [self.credentialsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self.containerView);
        make.width.equalTo(self.scrollView);
        make.left.mas_equalTo(self.generalView.mas_right);
    }];
    [self.sslView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.equalTo(self.containerView);
        make.width.equalTo(self.scrollView);
        make.left.mas_equalTo(self.credentialsView.mas_right);
    }];
    // 设置过渡视图的右距（此设置将影响到scrollView的contentSize）这个也是关键的一步
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sslView.mas_right);
    }];
    [self.settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.height.mas_equalTo(settingViewHeight);
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.index = scrollView.contentOffset.x / kViewWidth;
    [self loadButtonUI];
}

#pragma mark - MKMQTTGeneralParamsViewDelegate
- (void)mk_mqtt_generalParams_cleanSessionStatusChanged:(BOOL)isOn {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_switchStatusChanged:statusID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_switchStatusChanged:isOn statusID:0];
    }
}

- (void)mk_mqtt_generalParams_qosChanged:(NSInteger)qos {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_qosChanged:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_qosChanged:qos];
    }
}

- (void)mk_mqtt_generalParams_KeepAliveChanged:(NSString *)keepAlive {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:textID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:keepAlive textID:0];
    }
}

#pragma mark - MKMQTTUserCredentialsViewDelegate
- (void)mk_mqtt_userCredentials_userNameChanged:(NSString *)userName {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:textID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:userName textID:1];
    }
}

- (void)mk_mqtt_userCredentials_passwordChanged:(NSString *)password {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:textID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:password textID:2];
    }
}

#pragma mark - MKLFXCDMQTTSSLForDeviceViewDelegate
- (void)lfxc_mqtt_sslParams_device117D_sslStatusChanged:(BOOL)isOn {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_switchStatusChanged:statusID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_switchStatusChanged:isOn statusID:1];
    }
}

/// 用户选择了加密方式
/// @param certificate 0:CA signed server certificate     1:CA certificate     2:Self signed certificates
- (void)lfxc_mqtt_sslParams_device117D_certificateChanged:(NSInteger)certificate {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_certificateChanged:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_certificateChanged:certificate];
    }
}

/// 用户点击选择了caFaile按钮
- (void)lfxc_mqtt_sslParams_device117D_caFilePressed {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_fileButtonPressed:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_fileButtonPressed:0];
    }
}

/// 用户点击选择了Client Key按钮
- (void)lfxc_mqtt_sslParams_device117D_clientKeyPressed {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_fileButtonPressed:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_fileButtonPressed:1];
    }
}

/// 用户点击了Client Cert File按钮
- (void)lfxc_mqtt_sslParams_device117D_clientCertPressed {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_fileButtonPressed:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_fileButtonPressed:2];
    }
}

#pragma mark - MKLFXCDServerConfigDeviceSettingViewDelegate
- (void)lfxc_mqtt_deviecSetting_117D_deviceIDChanged:(NSString *)deviceID {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:textID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:deviceID textID:3];
    }
}

- (void)lfxc_mqtt_deviecSetting_117D_ntpURLChanged:(NSString *)url {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:textID:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_textFieldValueChanged:url textID:4];
    }
}

- (void)lfxc_mqtt_deviecSetting_117D_timeZoneChanged:(NSInteger)timeZone {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_timeZoneChanged:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_timeZoneChanged:timeZone];
    }
}

- (void)lfxc_mqtt_deviecSetting_117D_domainChanged:(NSInteger)domain {
    if ([self.delegate respondsToSelector:@selector(lfxc_mqtt_serverForDevice_117D_domainChanged:)]) {
        [self.delegate lfxc_mqtt_serverForDevice_117D_domainChanged:domain];
    }
}

#pragma mark - event method
- (void)generalButtonPressed {
    if (self.index == 0) {
        return;
    }
    self.index = 0;
    [self loadButtonUI];
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)credentialsButtonPressed {
    if (self.index == 1) {
        return;
    }
    self.index = 1;
    [self loadButtonUI];
    [self.scrollView setContentOffset:CGPointMake(kViewWidth, 0) animated:YES];
}

- (void)sslButtonPressed {
    if (self.index == 2) {
        return;
    }
    self.index = 2;
    [self loadButtonUI];
    [self.scrollView setContentOffset:CGPointMake(2 * kViewWidth, 0) animated:YES];
}

#pragma mark - public method
- (CGFloat)fetchHeightWithSSLStatus:(BOOL)isOn
                         CAFileName:(NSString *)caFile
                      clientKeyName:(NSString *)clientKeyName
                     clientCertName:(NSString *)clientCertName
                        certificate:(NSInteger)certificate {
    if (!isOn || certificate == 0) {
        //ssl关闭或者不需要证书
        return defaultScrollViewHeight + settingViewHeight;
    }
    CGSize caSize = [NSString sizeWithText:caFile
                                   andFont:MKFont(13.f)
                                andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f - 120.f -  2 * 10.f - 40.f, MAXFLOAT)];
    if (certificate == 1) {
        //CA 证书
        return defaultScrollViewHeight + settingViewHeight + caSize.height;
    }
    if (certificate == 2) {
        //CA证书和client key证书、client cert证书
        CGSize clientKeySize = [NSString sizeWithText:clientKeyName
                                              andFont:MKFont(13.f)
                                           andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f - 120.f -  2 * 10.f - 40.f, MAXFLOAT)];
        CGSize clientCertSize = [NSString sizeWithText:clientCertName
                                               andFont:MKFont(13.f)
                                            andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f - 120.f -  2 * 10.f - 40.f, MAXFLOAT)];
        return defaultScrollViewHeight + settingViewHeight + caSize.height + clientKeySize.height + clientCertSize.height;
    }
    return defaultScrollViewHeight + settingViewHeight;
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCDServerConfigDeviceFooterViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCDServerConfigDeviceFooterViewModel.class]) {
        return;
    }
    MKMQTTGeneralParamsViewModel *generalModel = [[MKMQTTGeneralParamsViewModel alloc] init];
    generalModel.clean = _dataModel.cleanSession;
    generalModel.qos = _dataModel.qos;
    generalModel.keepAlive = _dataModel.keepAlive;
    self.generalView.dataModel = generalModel;
    
    MKMQTTUserCredentialsViewModel *credentialsViewModel = [[MKMQTTUserCredentialsViewModel alloc] init];
    credentialsViewModel.userName = _dataModel.userName;
    credentialsViewModel.password = _dataModel.password;
    self.credentialsView.dataModel = credentialsViewModel;
    
    MKLFXCDMQTTSSLForDeviceViewModel *sslModel = [[MKLFXCDMQTTSSLForDeviceViewModel alloc] init];
    sslModel.sslIsOn = _dataModel.sslIsOn;
    sslModel.certificate = _dataModel.certificate;
    sslModel.caFileName = _dataModel.caFileName;
    sslModel.clientKeyName = _dataModel.clientKeyName;
    sslModel.clientCertName = _dataModel.clientCertName;
    self.sslView.dataModel = sslModel;
    
    MKLFXCDServerConfigDeviceSettingViewModel *settingModel = [[MKLFXCDServerConfigDeviceSettingViewModel alloc] init];
    settingModel.deviceID = _dataModel.deviceID;
    settingModel.ntpHost = _dataModel.ntpHost;
    settingModel.timeZone = _dataModel.timeZone;
    settingModel.domain = _dataModel.domain;
    self.settingView.dataModel = settingModel;
    
    [self loadSubViews];
    [self setNeedsLayout];
}

#pragma mark - private method
- (void)loadButtonUI {
    if (self.index == 0) {
        [self.generalButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
        [self.credentialsButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        [self.sslButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        return;
    }
    if (self.index == 1) {
        [self.generalButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        [self.credentialsButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
        [self.sslButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        return;
    }
    if (self.index == 2) {
        [self.generalButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        [self.credentialsButton setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
        [self.sslButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
        return;
    }
}

- (void)loadSubViews {
    if (self.topLineView.superview) {
        [self.topLineView removeFromSuperview];
    }
    if (self.generalButton.superview) {
        [self.generalButton removeFromSuperview];
    }
    if (self.credentialsButton.superview) {
        [self.credentialsButton removeFromSuperview];
    }
    if (self.sslButton.superview) {
        [self.sslButton removeFromSuperview];
    }
    if (self.scrollView.superview) {
        [self.scrollView removeFromSuperview];
    }
    if (self.containerView.superview) {
        [self.containerView removeFromSuperview];
    }
    if (self.generalView.superview) {
        [self.generalView removeFromSuperview];
    }
    if (self.credentialsView.superview) {
        [self.credentialsView removeFromSuperview];
    }
    if (self.sslView.superview) {
        [self.sslView removeFromSuperview];
    }
    if (self.settingView.superview) {
        [self.settingView removeFromSuperview];
    }
    [self addSubview:self.topLineView];
    [self.topLineView addSubview:self.generalButton];
    [self.topLineView addSubview:self.credentialsButton];
    [self.topLineView addSubview:self.sslButton];
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.generalView];
    [self.containerView addSubview:self.credentialsView];
    [self.containerView addSubview:self.sslView];
    [self addSubview:self.settingView];
}

#pragma mark - getter
- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = RGBCOLOR(242, 242, 242);
    }
    return _topLineView;
}

- (UIButton *)generalButton {
    if (!_generalButton) {
        _generalButton = [self loadButtonWithTitle:@"General" action:@selector(generalButtonPressed)];
        [_generalButton setTitleColor:NAVBAR_COLOR_MACROS forState:UIControlStateNormal];
    }
    return _generalButton;
}

- (MKMQTTGeneralParamsView *)generalView {
    if (!_generalView) {
        _generalView = [[MKMQTTGeneralParamsView alloc] init];
        _generalView.delegate = self;
    }
    return _generalView;
}

- (UIButton *)credentialsButton {
    if (!_credentialsButton) {
        _credentialsButton = [self loadButtonWithTitle:@"User Credentials" action:@selector(credentialsButtonPressed)];
    }
    return _credentialsButton;
}

- (MKMQTTUserCredentialsView *)credentialsView {
    if (!_credentialsView) {
        _credentialsView = [[MKMQTTUserCredentialsView alloc] init];
        _credentialsView.delegate = self;
    }
    return _credentialsView;
}

- (UIButton *)sslButton {
    if (!_sslButton) {
        _sslButton = [self loadButtonWithTitle:@"SSL/TLS" action:@selector(sslButtonPressed)];
    }
    return _sslButton;
}

- (MKLFXCDMQTTSSLForDeviceView *)sslView {
    if (!_sslView) {
        _sslView = [[MKLFXCDMQTTSSLForDeviceView alloc] init];
        _sslView.delegate = self;
    }
    return _sslView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

- (MKLFXCDServerConfigDeviceSettingView *)settingView {
    if (!_settingView) {
        _settingView = [[MKLFXCDServerConfigDeviceSettingView alloc] init];
        _settingView.delegate = self;
    }
    return _settingView;
}

- (UIButton *)loadButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:DEFAULT_TEXT_COLOR forState:UIControlStateNormal];
    [button.titleLabel setFont:MKFont(12.f)];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
