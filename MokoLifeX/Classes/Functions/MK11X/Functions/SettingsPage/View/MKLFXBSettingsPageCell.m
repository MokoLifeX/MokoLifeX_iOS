//
//  MKLFXBSettingsPageCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBSettingsPageCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKLFXBSettingsPageCellModel
@end

@interface MKLFXBSettingsPageCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *rightLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKLFXBSettingsPageCell

+ (MKLFXBSettingsPageCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXBSettingsPageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXBSettingsPageCellIdenty"];
    if (!cell) {
        cell = [[MKLFXBSettingsPageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXBSettingsPageCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.rightLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.rightIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(15.f);
    }];
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-3.f);
        make.width.mas_equalTo(50.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.rightLabel.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXBSettingsPageCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXBSettingsPageCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.leftMsg);
    self.rightLabel.text = SafeStr(_dataModel.rightMsg);
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

- (UILabel *)rightLabel {
    if (!_rightLabel) {
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.textColor = DEFAULT_TEXT_COLOR;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.font = MKFont(12.f);
    }
    return _rightLabel;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADICON(@"MokoLifeX", @"MKLFXBSettingsPageCell", @"mk_lfx_goNextIcon.png");
    }
    return _rightIcon;
}

@end
