//
//  MKLFXCDModifyServerSSLTextField.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDModifyServerSSLTextField.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKCustomUIAdopter.h"

@implementation MKLFXCDModifyServerSSLTextFieldModel
@end

@interface MKLFXCDModifyServerSSLTextField ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@end

@implementation MKLFXCDModifyServerSSLTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.msgLabel];
        [self addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(130.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(25.f);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCDModifyServerSSLTextFieldModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCDModifyServerSSLTextFieldModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.textType = _dataModel.textFieldType;
    self.textField.placeholder = SafeStr(_dataModel.textPlaceholder);
    self.textField.text = SafeStr(_dataModel.textFieldValue);
    self.textField.maxLength = _dataModel.maxLength;
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(14.f);
    }
    return _msgLabel;
}

- (MKTextField *)textField {
    if (!_textField) {
        _textField = [MKCustomUIAdopter customNormalTextFieldWithText:@"" placeHolder:@"" textType:mk_normal];
        @weakify(self);
        _textField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxc_117d_modifyServerSSLTextFieldValueChanged:textValue:)]) {
                [self.delegate lfxc_117d_modifyServerSSLTextFieldValueChanged:self.dataModel.index textValue:text];
            }
        };
    }
    return _textField;
}

@end
