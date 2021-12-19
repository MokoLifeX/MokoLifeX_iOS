//
//  MKLFXCDModifyServerSSLView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDModifyServerSSLView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKCustomUIAdopter.h"
#import "MKPickerView.h"
#import "MKTextField.h"

#import "MKLFXCDModifyServerSSLTextField.h"

static CGFloat const textFieldHeight = 30.f;

@implementation MKLFXCDModifyServerSSLViewModel
@end

@interface MKLFXCDModifyServerSSLView ()<MKLFXCDModifyServerSSLTextFieldDelegate>

@property (nonatomic, strong)UILabel *sslLabel;

@property (nonatomic, strong)UIButton *sslButton;

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)UILabel *certificateLabel;

@property (nonatomic, strong)UIButton *certificateButton;

@property (nonatomic, strong)MKLFXCDModifyServerSSLTextField *hostView;

@property (nonatomic, strong)MKLFXCDModifyServerSSLTextField *portView;

@property (nonatomic, strong)MKLFXCDModifyServerSSLTextField *caFileView;

@property (nonatomic, strong)MKLFXCDModifyServerSSLTextField *clientKeyView;

@property (nonatomic, strong)MKLFXCDModifyServerSSLTextField *clientCertView;

@end

@implementation MKLFXCDModifyServerSSLView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.sslLabel];
        [self addSubview:self.sslButton];
        [self addSubview:self.bottomView];
        [self.bottomView addSubview:self.certificateLabel];
        [self.bottomView addSubview:self.certificateButton];
        [self.bottomView addSubview:self.hostView];
        [self.bottomView addSubview:self.portView];
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
    [self.hostView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.certificateButton.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.portView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.hostView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.caFileView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.portView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.clientKeyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.caFileView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(textFieldHeight);
    }];
    [self.clientCertView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.clientKeyView.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(textFieldHeight);
    }];
}

#pragma mark - MKLFXCDModifyServerSSLTextFieldDelegate
/// textField内容发送改变时的回调事件
/// @param index 当前cell所在的index
/// @param value 当前textField的值
- (void)lfxc_117d_modifyServerSSLTextFieldValueChanged:(NSInteger)index textValue:(NSString *)value {
    if ([self.delegate respondsToSelector:@selector(lfxc_117d_mqtt_sslParams_modifyDevice_textFieldValueChanged:textValue:)]) {
        [self.delegate lfxc_117d_mqtt_sslParams_modifyDevice_textFieldValueChanged:index value:value];
    }
}

#pragma mark - event method
- (void)sslButtonPressed {
    self.sslButton.selected = !self.sslButton.selected;
    [self updateSSLButtonIcon];
    self.bottomView.hidden = !self.sslButton.selected;
    if ([self.delegate respondsToSelector:@selector(lfxc_117d_mqtt_sslParams_modifyDevice_sslStatusChanged:)]) {
        [self.delegate lfxc_117d_mqtt_sslParams_modifyDevice_sslStatusChanged:self.sslButton.selected];
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
        if ([self.delegate respondsToSelector:@selector(lfxc_117d_mqtt_sslParams_modifyDevice_certificateChanged:)]) {
            [self.delegate lfxc_117d_mqtt_sslParams_modifyDevice_certificateChanged:currentRow];
        }
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCDModifyServerSSLViewModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCDModifyServerSSLViewModel.class]) {
        return;
    }
    self.sslButton.selected = _dataModel.sslIsOn;
    [self updateSSLButtonIcon];
    NSArray *dataList = @[@"CA signed server certificate",@"CA certificate",@"Self signed certificates"];
    [self.certificateButton setTitle:dataList[_dataModel.certificate] forState:UIControlStateNormal];
    [self updateCertificateView:_dataModel.certificate];
    
    MKLFXCDModifyServerSSLTextFieldModel *hostModel = [[MKLFXCDModifyServerSSLTextFieldModel alloc] init];
    hostModel.index = 0;
    hostModel.msg = @"Host";
    hostModel.textPlaceholder = @"1-64Characters";
    hostModel.textFieldType = mk_normal;
    hostModel.textFieldValue = SafeStr(_dataModel.sslHost);
    hostModel.maxLength = 64;
    self.hostView.dataModel = hostModel;
    
    MKLFXCDModifyServerSSLTextFieldModel *portModel = [[MKLFXCDModifyServerSSLTextFieldModel alloc] init];
    portModel.index = 1;
    portModel.msg = @"Port";
    portModel.textPlaceholder = @"0-65535";
    portModel.textFieldType = mk_realNumberOnly;
    portModel.textFieldValue = SafeStr(_dataModel.sslPort);
    portModel.maxLength = 5;
    self.portView.dataModel = portModel;
    
    MKLFXCDModifyServerSSLTextFieldModel *caModel = [[MKLFXCDModifyServerSSLTextFieldModel alloc] init];
    caModel.index = 2;
    caModel.msg = @"CA File Path";
    caModel.textPlaceholder = @"1-100Characters";
    caModel.textFieldType = mk_normal;
    caModel.textFieldValue = SafeStr(_dataModel.caFilePath);
    caModel.maxLength = 100;
    self.caFileView.dataModel = caModel;
    
    MKLFXCDModifyServerSSLTextFieldModel *clientKeyModel = [[MKLFXCDModifyServerSSLTextFieldModel alloc] init];
    clientKeyModel.index = 3;
    clientKeyModel.msg = @"Client Key File";
    clientKeyModel.textPlaceholder = @"1-100Characters";
    clientKeyModel.textFieldType = mk_normal;
    clientKeyModel.textFieldValue = SafeStr(_dataModel.clientKeyPath);
    clientKeyModel.maxLength = 100;
    self.clientKeyView.dataModel = clientKeyModel;
    
    MKLFXCDModifyServerSSLTextFieldModel *clientModel = [[MKLFXCDModifyServerSSLTextFieldModel alloc] init];
    clientModel.index = 4;
    clientModel.msg = @"Client Cert File";
    clientModel.textPlaceholder = @"1-100Characters";
    clientModel.textFieldType = mk_normal;
    clientModel.textFieldValue = SafeStr(_dataModel.clientCertPath);
    clientModel.maxLength = 100;
    self.clientCertView.dataModel = clientModel;
    
    self.bottomView.hidden = !_dataModel.sslIsOn;
}

#pragma mark - private method
- (void)updateSSLButtonIcon {
    UIImage *image = (self.sslButton.selected ? LOADICON(@"MokoLifeX", @"MKLFXCDModifyServerSSLView", @"lfx_switchSelectedIcon.png") : LOADICON(@"MokoLifeX", @"MKLFXCDModifyServerSSLView", @"lfx_switchUnselectedIcon.png"));
    [self.sslButton setImage:image forState:UIControlStateNormal];
}

- (void)updateCertificateView:(NSInteger)certificate {
    if (certificate == 0) {
        //隐藏下面的证书相关
        self.hostView.hidden = YES;
        self.portView.hidden = YES;
        self.caFileView.hidden = YES;
        self.clientCertView.hidden = YES;
        self.clientKeyView.hidden = YES;
        return;
    }
    if (certificate == 1) {
        //只保留CA证书
        self.hostView.hidden = NO;
        self.portView.hidden = NO;
        self.caFileView.hidden = NO;
        self.clientCertView.hidden = YES;
        self.clientKeyView.hidden = YES;
        return;
    }
    //双向验证
    self.hostView.hidden = NO;
    self.portView.hidden = NO;
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
        [_sslButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCDModifyServerSSLView", @"lfx_switchUnselectedIcon.png") forState:UIControlStateNormal];
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

- (MKLFXCDModifyServerSSLTextField *)hostView {
    if (!_hostView) {
        _hostView = [[MKLFXCDModifyServerSSLTextField alloc] init];
        _hostView.delegate = self;
    }
    return _hostView;
}

- (MKLFXCDModifyServerSSLTextField *)portView {
    if (!_portView) {
        _portView = [[MKLFXCDModifyServerSSLTextField alloc] init];
        _portView.delegate = self;
    }
    return _portView;
}

- (MKLFXCDModifyServerSSLTextField *)caFileView {
    if (!_caFileView) {
        _caFileView = [[MKLFXCDModifyServerSSLTextField alloc] init];
        _caFileView.delegate = self;
    }
    return _caFileView;
}

- (MKLFXCDModifyServerSSLTextField *)clientKeyView {
    if (!_clientKeyView) {
        _clientKeyView = [[MKLFXCDModifyServerSSLTextField alloc] init];
        _clientKeyView.delegate = self;
    }
    return _clientKeyView;
}

- (MKLFXCDModifyServerSSLTextField *)clientCertView {
    if (!_clientCertView) {
        _clientCertView = [[MKLFXCDModifyServerSSLTextField alloc] init];
        _clientCertView.delegate = self;
    }
    return _clientCertView;
}

@end
