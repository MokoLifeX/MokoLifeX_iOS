//
//  MKMeasuredPowerLEDCell.m
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKMeasuredPowerLEDCell.h"

#import "MKMeasuredPowerLEDModel.h"

@interface MKMeasuredPowerLEDCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UITextField *textField;

@end

@implementation MKMeasuredPowerLEDCell

+ (MKMeasuredPowerLEDCell *)initCellWithTableView:(UITableView *)tableView {
    MKMeasuredPowerLEDCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKMeasuredPowerLEDCellIdenty"];
    if (!cell) {
        cell = [[MKMeasuredPowerLEDCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKMeasuredPowerLEDCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = COLOR_WHITE_MACROS;
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(5.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(3.f);
        make.bottom.mas_equalTo(-5.f);
    }];
}

#pragma mark - event method
- (void)textFieldValueChanged {
    if ([self.delegate respondsToSelector:@selector(measuredPowerLEDColorChanged:row:)]) {
        [self.delegate measuredPowerLEDColorChanged:self.textField.text row:self.dataModel.row];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKMeasuredPowerLEDModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.placeholder = SafeStr(_dataModel.placeholder);
    self.textField.text = SafeStr(dataModel.textValue);
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

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = MKFont(14.f);
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.cornerRadius = 5.f;
        [_textField addTarget:self
                       action:@selector(textFieldValueChanged)
             forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

@end
