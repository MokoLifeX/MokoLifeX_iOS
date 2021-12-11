//
//  MKLFXOperationStepsCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/20.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXOperationStepsCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@implementation MKLFXOperationStepsCellModel
@end

@interface MKLFXOperationStepsCell ()

@property (nonatomic, strong)UILabel *titleLabel;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKLFXOperationStepsCell

+ (MKLFXOperationStepsCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXOperationStepsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXOperationStepsCellIdenty"];
    if (!cell) {
        cell = [[MKLFXOperationStepsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXOperationStepsCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = RGBCOLOR(243, 243, 243);
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    CGSize msgSize = [NSString sizeWithText:self.msgLabel.text
                                    andFont:self.msgLabel.font
                                 andMaxSize:CGSizeMake(kViewWidth - 2 * 15.f, MAXFLOAT)];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(msgSize.height);
    }];
    [self.leftIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25.f);
        make.width.mas_equalTo(108.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(115.f);
    }];
    [self.rightIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-25.f);
        make.width.mas_equalTo(108.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(115.f);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXOperationStepsCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXOperationStepsCellModel.class]) {
        return;
    }
    self.titleLabel.text = SafeStr(_dataModel.titleMsg);
    self.msgLabel.text = SafeStr(_dataModel.noteMsg);
    self.leftIcon.image = LOADICON(@"MokoLifeX", @"MKLFXOperationStepsCell", _dataModel.leftIconName);
    self.rightIcon.image = LOADICON(@"MokoLifeX", @"MKLFXOperationStepsCell", _dataModel.rightIconName);
    
    [self setNeedsLayout];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = NAVBAR_COLOR_MACROS;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = MKFont(15.f);
    }
    return _titleLabel;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = RGBCOLOR(143, 143, 143);
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(13.f);
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (UIImageView *)leftIcon {
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
    }
    return _leftIcon;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
    }
    return _rightIcon;
}

@end
