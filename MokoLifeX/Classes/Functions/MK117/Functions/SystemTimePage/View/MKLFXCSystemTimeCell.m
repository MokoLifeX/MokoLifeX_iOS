//
//  MKLFXCSystemTimeCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSystemTimeCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKCustomUIAdopter.h"

@implementation MKLFXCSystemTimeCellModel
@end

@interface MKLFXCSystemTimeCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *syncButton;

@end

@implementation MKLFXCSystemTimeCell

+ (MKLFXCSystemTimeCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXCSystemTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXCSystemTimeCellIdenty"];
    if (!cell) {
        cell = [[MKLFXCSystemTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXCSystemTimeCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.syncButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.syncButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.syncButton.mas_left).mas_offset(-10.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - event method
- (void)syncButtonPressed {
    if ([self.delegate respondsToSelector:@selector(lfxc_syncTimeFromPhone)]) {
        [self.delegate lfxc_syncTimeFromPhone];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCSystemTimeCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCSystemTimeCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    [self.syncButton setTitle:_dataModel.buttonTitle forState:UIControlStateNormal];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.font = MKFont(14.f);
    }
    return _msgLabel;
}

- (UIButton *)syncButton {
    if (!_syncButton) {
        _syncButton = [MKCustomUIAdopter customButtonWithTitle:@""
                                                        target:self
                                                        action:@selector(syncButtonPressed)];
    }
    return _syncButton;
}

@end
