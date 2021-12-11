//
//  MKLFXCEnergyReportCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCEnergyReportCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKTextField.h"

@implementation MKLFXCEnergyReportCellModel
@end

@interface MKLFXCEnergyReportCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UILabel *noteMsgLabel;

@end

@implementation MKLFXCEnergyReportCell

+ (MKLFXCEnergyReportCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXCEnergyReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXCEnergyReportCellIdenty"];
    if (!cell) {
        cell = [[MKLFXCEnergyReportCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXCEnergyReportCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.noteMsgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(30.f);
    }];
    CGSize noteSize = [NSString sizeWithText:self.noteMsgLabel.text
                                     andFont:self.noteMsgLabel.font
                                  andMaxSize:CGSizeMake(kViewWidth - 2 * 15.f, MAXFLOAT)];
    [self.noteMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.textField.mas_bottom).mas_offset(5.f);
        make.height.mas_equalTo(noteSize.height);
    }];
}

#pragma mark - setter

- (void)setDataModel:(MKLFXCEnergyReportCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCEnergyReportCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.text = SafeStr(_dataModel.textValue);
    self.textField.maxLength = _dataModel.maxLen;
    self.noteMsgLabel.text = _dataModel.noteMsg;
    [self setNeedsLayout];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (MKTextField *)textField {
    if (!_textField) {
        _textField = [[MKTextField alloc] initWithTextFieldType:mk_realNumberOnly];
        @weakify(self);
        _textField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(lfxc_textFieldValueChanged:index:)]) {
                [self.delegate lfxc_textFieldValueChanged:text index:self.dataModel.index];
            }
        };
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

- (UILabel *)noteMsgLabel {
    if (!_noteMsgLabel) {
        _noteMsgLabel = [[UILabel alloc] init];
        _noteMsgLabel.textColor = RGBCOLOR(207, 207, 207);
        _noteMsgLabel.textAlignment = NSTextAlignmentLeft;
        _noteMsgLabel.font = MKFont(13.f);
        _noteMsgLabel.numberOfLines = 0;
    }
    return _noteMsgLabel;
}

@end
