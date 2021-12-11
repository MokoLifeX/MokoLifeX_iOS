//
//  MKLFXAMQTTSSLForDeviceView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/22.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAMQTTSSLForDeviceView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCustomUIAdopter.h"
#import "MKPickerView.h"
#import "MKMQTTSSLCertificateView.h"

@implementation MKLFXAMQTTSSLForDeviceViewModel
@end

@interface MKLFXAMQTTSSLForDeviceView ()<MKMQTTSSLCertificateViewDelegate>

@property (nonatomic, strong)UILabel *sslLabel;

@property (nonatomic, strong)UIButton *sslButton;

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)UILabel *certificateLabel;

@property (nonatomic, strong)UIButton *certificateButton;

@property (nonatomic, strong)MKMQTTSSLCertificateView *caFileView;

@property (nonatomic, strong)MKMQTTSSLCertificateView *clientKeyView;

@property (nonatomic, strong)MKMQTTSSLCertificateView *clientCertView;

@end

@implementation MKLFXAMQTTSSLForDeviceView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.sslLabel];
        [self addSubview:self.sslButton];
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.certificateLabel];
        [self.bottomView addSubview:self.certificateButton];
        [self.bottomView addSubview:self.caFileView];
        [self.bottomView addSubview:self.clientKeyView];
        [self.bottomView addSubview:self.clientCertView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.sslButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(30.f);
    }];
    [self.sslLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(120.f);
        make.centerY.mas_equalTo(self.sslButton.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.sslButton.mas_bottom).mas_offset(10.f);
        make.bottom.mas_equalTo(0);
    }];
    [self.certificateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.left.mas_equalTo(self.certificateLabel.mas_right).mas_offset(10.f);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(30.f);
    }];
    [self.certificateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(120.f);
        make.centerY.mas_equalTo(self.certificateButton.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    CGSize caSize = [NSString sizeWithText:self.dataModel.caFileName
                                   andFont:MKFont(13.f)
                                andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f - 120.f -  2 * 10.f - 40.f, MAXFLOAT)];
    [self.caFileView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.certificateButton.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(caSize.height + 30.f);
    }];
    CGSize clientKeySize = [NSString sizeWithText:self.dataModel.clientKeyName
                                          andFont:MKFont(13.f)
                                       andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f - 120.f -  2 * 10.f - 40.f, MAXFLOAT)];
    [self.clientKeyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.caFileView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(clientKeySize.height + 30.f);
    }];
    CGSize clientSize = [NSString sizeWithText:self.dataModel.clientCertName
                                       andFont:MKFont(13.f)
                                    andMaxSize:CGSizeMake(self.frame.size.width - 2 * 15.f - 120.f -  2 * 10.f - 40.f, MAXFLOAT)];
    [self.clientCertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.clientKeyView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(clientSize.height + 30.f);
    }];
}

#pragma mark - MKMQTTSSLCertificateViewDelegate
- (void)mk_fileSelectedButtonPressed:(NSInteger)index {
    if (index == 0) {
        //CA File
        if ([self.delegate respondsToSelector:@selector(lfxa_mqtt_sslParams_device_caFilePressed)]) {
            [self.delegate lfxa_mqtt_sslParams_device_caFilePressed];
        }
        return;
    }
    if (index == 1) {
        //Client Key File
        if ([self.delegate respondsToSelector:@selector(lfxa_mqtt_sslParams_device_clientKeyPressed)]) {
            [self.delegate lfxa_mqtt_sslParams_device_clientKeyPressed];
        }
        return;
    }
    //Client Cert File
    if ([self.delegate respondsToSelector:@selector(lfxa_mqtt_sslParams_device_clientCertPressed)]) {
        [self.delegate lfxa_mqtt_sslParams_device_clientCertPressed];
    }
}

#pragma mark - event method
- (void)sslButtonPressed {
    self.sslButton.selected = !self.sslButton.selected;
    [self updateSSLButtonIcon];
    self.bottomView.hidden = !self.sslButton.selected;
    if ([self.delegate respondsToSelector:@selector(lfxa_mqtt_sslParams_device_sslStatusChanged:)]) {
        [self.delegate lfxa_mqtt_sslParams_device_sslStatusChanged:self.sslButton.selected];
    }
}

- (void)certificateButtonPressed {
    NSArray *dataList = @[@"CA signed server certificate",@"CA certificate",@"Self signed certificates"];
    NSInteger index = 0;
    for (NSInteger i = 0; i < dataList.count; i ++) {
        if ([self.certificateButton.titleLabel.text isEqualToString:dataList[i]]) {
            index = i;
            break;
        }
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    [pickView showPickViewWithDataList:dataList selectedRow:index block:^(NSInteger currentRow) {
        [self.certificateButton setTitle:dataList[currentRow] forState:UIControlStateNormal];
        [self updateCertificateView:currentRow];
        if ([self.delegate respondsToSelector:@selector(lfxa_mqtt_sslParams_device_certificateChanged:)]) {
            [self.delegate lfxa_mqtt_sslParams_device_certificateChanged:currentRow];
        }
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXAMQTTSSLForDeviceViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXAMQTTSSLForDeviceViewModel.class]) {
        return;
    }
    self.sslButton.selected = _dataModel.sslIsOn;
    [self updateSSLButtonIcon];
    NSArray *dataList = @[@"CA signed server certificate",@"CA certificate",@"Self signed certificates"];
    [self.certificateButton setTitle:dataList[_dataModel.certificate] forState:UIControlStateNormal];
    [self updateCertificateView:_dataModel.certificate];
    
    MKMQTTSSLCertificateViewModel *caModel = [[MKMQTTSSLCertificateViewModel alloc] init];
    caModel.index = 0;
    caModel.msg = @"CA File";
    caModel.fileName = _dataModel.caFileName;
    self.caFileView.dataModel = caModel;
    
    MKMQTTSSLCertificateViewModel *clientKeyModel = [[MKMQTTSSLCertificateViewModel alloc] init];
    clientKeyModel.index = 1;
    clientKeyModel.msg = @"Client Key";
    clientKeyModel.fileName = _dataModel.clientKeyName;
    self.clientKeyView.dataModel = clientKeyModel;
    
    MKMQTTSSLCertificateViewModel *clientModel = [[MKMQTTSSLCertificateViewModel alloc] init];
    clientModel.index = 2;
    clientModel.msg = @"Client Cert File";
    clientModel.fileName = _dataModel.clientCertName;
    self.clientCertView.dataModel = clientModel;
    
    self.bottomView.hidden = !_dataModel.sslIsOn;
}

#pragma mark - private method
- (void)updateSSLButtonIcon {
    UIImage *image = (self.sslButton.selected ? LOADICON(@"MokoLifeX", @"MKLFXAMQTTSSLForDeviceView", @"lfx_switchSelectedIcon.png") : LOADICON(@"MokoLifeX", @"MKLFXAMQTTSSLForDeviceView", @"lfx_switchUnselectedIcon.png"));
    [self.sslButton setImage:image forState:UIControlStateNormal];
}

- (void)updateCertificateView:(NSInteger)certificate {
    if (certificate == 0) {
        //隐藏下面的证书相关
        self.caFileView.hidden = YES;
        self.clientCertView.hidden = YES;
        self.clientKeyView.hidden = YES;
        return;
    }
    if (certificate == 1) {
        //只保留CA证书
        self.caFileView.hidden = NO;
        self.clientCertView.hidden = YES;
        self.clientKeyView.hidden = YES;
        return;
    }
    //双向验证
    self.caFileView.hidden = NO;
    self.clientCertView.hidden = NO;
    self.clientKeyView.hidden = NO;
}

#pragma mark - getter
- (UILabel *)sslLabel {
    if (!_sslLabel) {
        _sslLabel = [[UILabel alloc] init];
        _sslLabel.textColor = DEFAULT_TEXT_COLOR;
        _sslLabel.font = MKFont(15.f);
        _sslLabel.textAlignment = NSTextAlignmentLeft;
        _sslLabel.text = @"SSL/TLS";
    }
    return _sslLabel;
}

- (UIButton *)sslButton {
    if (!_sslButton) {
        _sslButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sslButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCMQTTSSLForDeviceView", @"lfx_switchUnselectedIcon.png") forState:UIControlStateNormal];
        [_sslButton addTarget:self
                       action:@selector(sslButtonPressed)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _sslButton;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)certificateLabel {
    if (!_certificateLabel) {
        _certificateLabel = [[UILabel alloc] init];
        _certificateLabel.textColor = DEFAULT_TEXT_COLOR;
        _certificateLabel.textAlignment = NSTextAlignmentLeft;
        _certificateLabel.font = MKFont(13.f);
        _certificateLabel.text = @"Certificate";
    }
    return _certificateLabel;
}

- (UIButton *)certificateButton {
    if (!_certificateButton) {
        _certificateButton = [MKCustomUIAdopter customButtonWithTitle:@"CA signed server certificate"
                                                               target:self
                                                               action:@selector(certificateButtonPressed)];
        [_certificateButton.titleLabel setFont:MKFont(13.f)];
    }
    return _certificateButton;
}

- (MKMQTTSSLCertificateView *)caFileView {
    if (!_caFileView) {
        _caFileView = [[MKMQTTSSLCertificateView alloc] init];
        _caFileView.delegate = self;
    }
    return _caFileView;
}

- (MKMQTTSSLCertificateView *)clientKeyView {
    if (!_clientKeyView) {
        _clientKeyView = [[MKMQTTSSLCertificateView alloc] init];
        _clientKeyView.delegate = self;
    }
    return _clientKeyView;
}

- (MKMQTTSSLCertificateView *)clientCertView {
    if (!_clientCertView) {
        _clientCertView = [[MKMQTTSSLCertificateView alloc] init];
        _clientCertView.delegate = self;
    }
    return _clientCertView;
}

@end
