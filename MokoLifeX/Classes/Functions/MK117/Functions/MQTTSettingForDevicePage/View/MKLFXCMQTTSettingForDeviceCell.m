//
//  MKLFXCMQTTSettingForDeviceCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTSettingForDeviceCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"

@implementation MKLFXCMQTTSettingForDeviceCellModel

- (CGFloat)fetchCellHeight {
    CGSize size = [NSString sizeWithText:self.rightMsg
                                 andFont:MKFont(13.f)
                              andMaxSize:CGSizeMake(kViewWidth / 2 - 15.f - 5.f, MAXFLOAT)];
    return MAX(44.f, size.height + 10.f);
}

@end

@interface MKLFXCMQTTSettingForDeviceCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *rightMsgLabel;

@end

@implementation MKLFXCMQTTSettingForDeviceCell

+ (MKLFXCMQTTSettingForDeviceCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXCMQTTSettingForDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXCMQTTSettingForDeviceCellIdenty"];
    if (!cell) {
        cell = [[MKLFXCMQTTSettingForDeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXCMQTTSettingForDeviceCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.rightMsgLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    CGSize size = [NSString sizeWithText:self.rightMsgLabel.text
                                 andFont:self.rightMsgLabel.font
                              andMaxSize:CGSizeMake(self.contentView.frame.size.width / 2 - 15.f - 5.f, MAXFLOAT)];
    [self.rightMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(5.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(size.height);
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKLFXCMQTTSettingForDeviceCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXCMQTTSettingForDeviceCellModel.class]) {
        return;
    }
    self.msgLabel.text = SafeStr(_dataModel.msg);
    self.rightMsgLabel.text = SafeStr(_dataModel.rightMsg);
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

- (UILabel *)rightMsgLabel {
    if (!_rightMsgLabel) {
        _rightMsgLabel = [[UILabel alloc] init];
        _rightMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _rightMsgLabel.textAlignment = NSTextAlignmentLeft;
        _rightMsgLabel.font = MKFont(13.f);
        _rightMsgLabel.numberOfLines = 0;
    }
    return _rightMsgLabel;
}

@end
