//
//  MKLFXBConfigDataCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBConfigDataCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKTextField.h"

@implementation MKLFXBConfigDataCellModel
@end

@interface MKLFXBConfigDataCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@end

@implementation MKLFXBConfigDataCell

+ (MKLFXBConfigDataCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXBConfigDataCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXBConfigDataCellIdenty"];
    if (!cell) {
        cell = [[MKLFXBConfigDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXBConfigDataCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
        make.top.mas_equalTo(15.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXBConfigDataCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXBConfigDataCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.placeholder = SafeStr(_dataModel.placeholder);
    self.textField.text = SafeStr(_dataModel.value);
    self.textField.maxLength = _dataModel.maxLen;
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
            if ([self.delegate respondsToSelector:@selector(lfxb_configDataValueChanged:index:)]) {
                [self.delegate lfxb_configDataValueChanged:text index:self.dataModel.index];
            }
        };
        
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.font = MKFont(14.f);
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.cornerRadius = 5.f;
    }
    return _textField;
}

@end
