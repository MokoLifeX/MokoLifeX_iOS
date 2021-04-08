//
//  MKTextFieldCell.m
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKTextFieldCell.h"

#import <Masonry/Masonry.h>

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@implementation MKTextFieldCellModel
@end

@interface MKTextFieldCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIView *textBorderView;

@property (nonatomic, strong)UITextField *textField;

@property (nonatomic, strong)UILabel *unitLabel;

@end

@implementation MKTextFieldCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (MKTextFieldCell *)initCellWithTableView:(UITableView *)tableView {
    MKTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKTextFieldCellIdenty"];
    if (!cell) {
        cell = [[MKTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKTextFieldCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textBorderView];
        [self.textBorderView addSubview:self.textField];
        [self.contentView addSubview:self.unitLabel];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(needHiddenKeyboard)
                                                     name:@"MKTextFieldNeedHiddenKeyboard"
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize msgSize = [NSString sizeWithText:self.msgLabel.text
                                    andFont:self.msgLabel.font
                                 andMaxSize:CGSizeMake(MAXFLOAT, MKFont(15.f).lineHeight)];
    CGFloat msgLabelWidth = msgSize.width;
    if (msgLabelWidth > (self.contentView.frame.size.width - 3 * 15) / 2) {
        msgLabelWidth = (self.contentView.frame.size.width - 3 * 15) / 2;
    }
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(msgLabelWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    if (ValidStr(self.dataModel.unit)) {
        [self.unitLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-15.f);
            make.width.mas_equalTo(50.f);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(MKFont(14.f).lineHeight);
        }];
        [self.textBorderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(15.f);
            make.right.mas_equalTo(self.unitLabel.mas_left).mas_offset(-5.f);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.height.mas_equalTo(30.f);
        }];
        return;
    }
    [self.textBorderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(15.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - event method
- (void)textFieldValueChanged {
    if (self.dataModel.maxLength > 0 && self.textField.text.length > self.dataModel.maxLength) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(mk_deviceTextCellValueChanged:textValue:)]) {
        [self.delegate mk_deviceTextCellValueChanged:self.dataModel.index textValue:SafeStr(self.textField.text)];
    }
}

#pragma mark - note
- (void)needHiddenKeyboard {
    [self.textField resignFirstResponder];
}

#pragma mark - setter
- (void)setDataModel:(MKTextFieldCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    if (self.textField && self.textField.superview) {
        [self.textField removeFromSuperview];
        self.textField = nil;
    }
    self.textField = [self textFieldWithPlaceholder:_dataModel.textPlaceholder
                                              value:_dataModel.textFieldValue
                                          maxLength:_dataModel.maxLength
                                               type:_dataModel.textFieldType];
    self.textField.clearButtonMode = _dataModel.clearButtonMode;
    [self.textBorderView addSubview:self.textField];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.f);
        make.right.mas_equalTo(-5.f);
        make.top.mas_equalTo(1.f);
        make.bottom.mas_equalTo(-1.f);
    }];
    self.unitLabel.text = SafeStr(_dataModel.unit);
    self.unitLabel.hidden = !ValidStr(_dataModel.unit);
    if (_dataModel.borderColor) {
        self.textBorderView.layer.borderColor = _dataModel.borderColor.CGColor;
    }
    [self setNeedsLayout];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (UIView *)textBorderView {
    if (!_textBorderView) {
        _textBorderView = [[UIView alloc] init];
        _textBorderView.layer.masksToBounds = YES;
        _textBorderView.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textBorderView.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textBorderView.layer.cornerRadius = 6.f;
    }
    return _textBorderView;
}

- (UILabel *)unitLabel {
    if (!_unitLabel) {
        _unitLabel = [[UILabel alloc] init];
        _unitLabel.textColor = DEFAULT_TEXT_COLOR;
        _unitLabel.textAlignment = NSTextAlignmentLeft;
        _unitLabel.font = MKFont(14.f);
    }
    return _unitLabel;
}

- (UITextField *)textFieldWithPlaceholder:(NSString *)placeholder
                                    value:(NSString *)value
                                maxLength:(NSInteger)maxLength
                                     type:(mk_CustomTextFieldType)type {
    UITextField *textField = [[UITextField alloc] initWithTextFieldType:type];
    textField.borderStyle = UITextBorderStyleNone;
    textField.maxLength = maxLength;
    textField.placeholder = placeholder;
    textField.text = value;
    textField.font = MKFont(13.f);
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    [textField addTarget:self
                  action:@selector(textFieldValueChanged)
        forControlEvents:UIControlEventEditingChanged];
    return textField;
}

@end
