//
//  MKLFXBOVMDFileCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBOVMDFileCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKTextField.h"

@implementation MKLFXBOVMDFileCellModel
@end

@interface MKLFXBOVMDFileCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)MKTextField *textField;

@property (nonatomic, strong)UIButton *fileButton;

@end

@implementation MKLFXBOVMDFileCell

+ (MKLFXBOVMDFileCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXBOVMDFileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXBOVMDFileCellIdenty"];
    if (!cell) {
        cell = [[MKLFXBOVMDFileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXBOVMDFileCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = RGBCOLOR(242, 242, 242);
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.fileButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(135.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.fileButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.msgLabel.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(self.fileButton.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - event method
- (void)fileButtonPressed {
    if ([self.delegate respondsToSelector:@selector(lfxb_certFileButtonPressed:)]) {
        [self.delegate lfxb_certFileButtonPressed:self.dataModel.index];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKLFXBOVMDFileCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXBOVMDFileCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.textField.text = SafeStr(_dataModel.certName);
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(13.f);
    }
    return _msgLabel;
}

- (MKTextField *)textField {
    if (!_textField) {
        _textField = [[MKTextField alloc] init];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.font = MKFont(12.f);
        _textField.textColor = DEFAULT_TEXT_COLOR;
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
        _textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
        _textField.layer.cornerRadius = 6.f;
        _textField.enabled = NO;
    }
    return _textField;
}

- (UIButton *)fileButton {
    if (!_fileButton) {
        _fileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fileButton setImage:LOADICON(@"MokoLifeX", @"MKLFXBOVMDFileCell", @"lfx_config_certAddIcon.png") forState:UIControlStateNormal];
        [_fileButton addTarget:self
                        action:@selector(fileButtonPressed)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _fileButton;
}

@end
