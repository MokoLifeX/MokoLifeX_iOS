//
//  MKLFXCOverThresholdCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/11.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCOverThresholdCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

#import "MKTextField.h"

@implementation MKLFXCOverThresholdCellModel
@end

@interface MKLFXCOverThresholdCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@end

@implementation MKLFXCOverThresholdCell

+ (MKLFXCOverThresholdCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXCOverThresholdCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXCOverThresholdCellIdenty"];
    if (!cell) {
        cell = [[MKLFXCOverThresholdCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXCOverThresholdCellIdenty"];
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
}

#pragma mark - event method
- (void)textValueChanged:(NSString *)text {
    if (self.dataModel.floatType && text.length >= 1) {
        //当前是全键盘，需要作出判断
        NSString *inputString = [text substringFromIndex:(text.length - 1)];
        if (![inputString regularExpressions:isRealNumbers] && ![inputString isEqualToString:@"."]) {
            //不是数字也不是.则表示不符合要求
            if (text.length == 1) {
                self.textField.text = @"";
            }else {
                self.textField.text = [text substringWithRange:NSMakeRange(0, text.length - 1)];
            }
            return;
        }
    }
    if ([self.delegate respondsToSelector:@selector(lfxc_textValueChanged:index:)]) {
        [self.delegate lfxc_textValueChanged:text index:self.dataModel.index];
    }
}

#pragma mark - setter

- (void)setDataModel:(MKLFXCOverThresholdCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCOverThresholdCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    
    self.textField.placeholder = SafeStr(_dataModel.placeholder);
    self.textField.textType = (_dataModel.floatType ? mk_normal : mk_realNumberOnly);
    self.textField.maxLength = _dataModel.maxLen;
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
            [self textValueChanged:text];
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

@end
