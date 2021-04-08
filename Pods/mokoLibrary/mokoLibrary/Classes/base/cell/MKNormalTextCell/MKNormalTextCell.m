//
//  MKNormalTextCell.m
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKNormalTextCell.h"

#import <Masonry/Masonry.h>
#import "MKMacroDefines.h"

@implementation MKNormalTextCellModel
@end


@interface MKNormalTextCell ()

@property (nonatomic, strong)UILabel *leftMsgLabel;

@property (nonatomic, strong)UILabel *rightMsgLabel;

@property (nonatomic, strong)UIImageView *rightIcon;

@end

@implementation MKNormalTextCell

+ (MKNormalTextCell *)initCellWithTableView:(UITableView *)tableView {
    MKNormalTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKNormalTextCellIdenty"];
    if (!cell) {
        cell = [[MKNormalTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKNormalTextCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftMsgLabel];
        [self.contentView addSubview:self.rightMsgLabel];
        [self.contentView addSubview:self.rightIcon];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.leftMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(-4.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.rightIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(14.f);
    }];
    [self.rightMsgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (self.dataModel.showRightIcon) {
            make.right.mas_equalTo(self.rightIcon.mas_left).mas_offset(-2.f);
        }else {
            make.right.mas_equalTo(-15.f);
        }
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(-2.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
}

#pragma mark -
- (void)setDataModel:(MKNormalTextCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.leftMsgLabel.text = (ValidStr(_dataModel.leftMsg) ? _dataModel.leftMsg : @"");
    self.rightMsgLabel.text = (ValidStr(_dataModel.rightMsg) ? _dataModel.rightMsg : @"");
    self.rightIcon.hidden = !_dataModel.showRightIcon;
    [self setNeedsLayout];
}

#pragma mark - setter & getter
- (UILabel *)leftMsgLabel {
    if (!_leftMsgLabel) {
        _leftMsgLabel = [[UILabel alloc] init];
        _leftMsgLabel.textColor = DEFAULT_TEXT_COLOR;
        _leftMsgLabel.textAlignment = NSTextAlignmentLeft;
        _leftMsgLabel.font = MKFont(15.f);
    }
    return _leftMsgLabel;
}

- (UILabel *)rightMsgLabel {
    if (!_rightMsgLabel) {
        _rightMsgLabel = [[UILabel alloc] init];
        _rightMsgLabel.textColor = UIColorFromRGB(0x808080);
        _rightMsgLabel.textAlignment = NSTextAlignmentRight;
        _rightMsgLabel.font = MKFont(13.f);
    }
    return _rightMsgLabel;
}

- (UIImageView *)rightIcon {
    if (!_rightIcon) {
        _rightIcon = [[UIImageView alloc] init];
        _rightIcon.image = LOADICON(@"MKNormalTextCell", @"go_next_button.png");
    }
    return _rightIcon;
}

@end
