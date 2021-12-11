//
//  MKLFXPowerOnStatusCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXPowerOnStatusCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

@implementation MKLFXPowerOnStatusCellModel
@end

@interface MKLFXPowerOnStatusCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *icon;

@end

@implementation MKLFXPowerOnStatusCell

+ (MKLFXPowerOnStatusCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXPowerOnStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXPowerOnStatusCellIdenty"];
    if (!cell) {
        cell = [[MKLFXPowerOnStatusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXPowerOnStatusCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.icon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.icon.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    CGSize iconSize = self.dataModel.icon.size;
    [self.icon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(iconSize.width);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(iconSize.height);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXPowerOnStatusCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXPowerOnStatusCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.icon.image = _dataModel.icon;
    [self setNeedsLayout];
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

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
    }
    return _icon;
}

@end
