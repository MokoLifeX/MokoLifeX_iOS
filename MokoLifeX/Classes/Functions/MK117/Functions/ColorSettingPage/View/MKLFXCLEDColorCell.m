//
//  MKLFXCLEDColorCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCLEDColorCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKTextField.h"

@implementation MKLFXCLEDColorCellModel
@end

@interface MKLFXCLEDColorCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@end

@implementation MKLFXCLEDColorCell

+ (MKLFXCLEDColorCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXCLEDColorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXCLEDColorCellIdenty"];
    if (!cell) {
        cell = [[MKLFXCLEDColorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXCLEDColorCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = UIColorFromRGB(0xf2f2f2);
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

#pragma mark - setter
- (void)setDataModel:(MKLFXCLEDColorCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCLEDColorCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.placeholder = SafeStr(_dataModel.placeholder);
    self.textField.text = SafeStr(_dataModel.textValue);
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
            if ([self.delegate respondsToSelector:@selector(lfxc_ledColorChanged:index:)]) {
                [self.delegate lfxc_ledColorChanged:text index:self.dataModel.index];
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
