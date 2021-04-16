//
//  MKTextButtonCell.m
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKTextButtonCell.h"

#import <Masonry/Masonry.h>

#import "MKMacroDefines.h"
#import "MKPickerView.h"

@implementation MKTextButtonCellModel
@end

@interface MKTextButtonCell ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIButton *selectedButton;

@end

@implementation MKTextButtonCell

+ (MKTextButtonCell *)initCellWithTableView:(UITableView *)tableView {
    MKTextButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKTextButtonCellIdenty"];
    if (!cell) {
        cell = [[MKTextButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKTextButtonCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.selectedButton];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews {
    [super layoutSubviews];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(self.selectedButton.mas_left).mas_offset(-5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(130.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - event method
- (void)selectedButtonPressed {
    //隐藏其他cell里面的输入框键盘
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKTextFieldNeedHiddenKeyboard" object:nil];
    NSInteger row = 0;
    for (NSInteger i = 0; i < self.dataModel.dataList.count; i ++) {
        if ([self.selectedButton.titleLabel.text isEqualToString:self.dataModel.dataList[i]]) {
            row = i;
            break;
        }
    }
    MKPickerView *pickView = [[MKPickerView alloc] init];
    pickView.dataList = self.dataModel.dataList;
    [pickView showPickViewWithIndex:row block:^(NSInteger currentRow) {
        [self.selectedButton setTitle:self.dataModel.dataList[currentRow] forState:UIControlStateNormal];
        if ([self.delegate respondsToSelector:@selector(mk_loraTextButtonCellSelected:dataListIndex:value:)]) {
            [self.delegate mk_loraTextButtonCellSelected:self.dataModel.index dataListIndex:currentRow value:self.dataModel.dataList[currentRow]];
        }
    }];
}

#pragma mark - setter
- (void)setDataModel:(MKTextButtonCellModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.textLabel.text = SafeStr(_dataModel.msg);
    [self.selectedButton setTitle:_dataModel.dataList[_dataModel.dataListIndex] forState:UIControlStateNormal];
    if (_dataModel.buttonBackColor) {
        [self.selectedButton setBackgroundColor:_dataModel.buttonBackColor];
    }
    if (_dataModel.buttonTitleColor) {
        [self.selectedButton setTitleColor:_dataModel.buttonTitleColor forState:UIControlStateNormal];
    }
}

#pragma mark - setter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectedButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_selectedButton setBackgroundColor:UIColorFromRGB(0x2F84D0)];
        [_selectedButton.layer setMasksToBounds:YES];
        [_selectedButton.layer setCornerRadius:6.f];
        [_selectedButton addTarget:self
                            action:@selector(selectedButtonPressed)
                  forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedButton;
}

@end
