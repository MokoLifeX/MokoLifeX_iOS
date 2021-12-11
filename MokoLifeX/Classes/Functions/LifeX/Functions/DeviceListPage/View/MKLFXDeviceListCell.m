//
//  MKLFXDeviceListCell.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXDeviceListCell.h"

#import "Masonry.h"

#import "MKMacroDefines.h"

#import "MKLFXDeviceModel.h"

@interface MKLFXDeviceListCell ()

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UIImageView *nextIcon;

@property (nonatomic, strong)UIButton *stateButton;

@end

@implementation MKLFXDeviceListCell

+ (MKLFXDeviceListCell *)initCellWithTableView:(UITableView *)tableView {
    MKLFXDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKLFXDeviceListCellIdenty"];
    if (!cell) {
        cell = [[MKLFXDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKLFXDeviceListCellIdenty"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.deviceNameLabel];
        [self.contentView addSubview:self.stateLabel];
        [self.contentView addSubview:self.nextIcon];
        [self.contentView addSubview:self.stateButton];
        [self addLongPressEventAction];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.leftIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(33.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(33.f);
    }];
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(5.f);
        make.right.mas_equalTo(self.nextIcon.mas_left).mas_offset(-10.f);
        make.top.mas_equalTo(10.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    [self.stateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(5.f);
        make.width.mas_equalTo(self.deviceNameLabel.mas_width);
        make.bottom.mas_equalTo(-10.f);
        make.height.mas_equalTo(MKFont(12.f).lineHeight);
    }];
    [self.nextIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.stateButton.mas_left).mas_offset(-15.f);
        make.width.mas_equalTo(8.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(14.f);
    }];
    [self.stateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(40.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30.f);
    }];
}

#pragma mark - event method
- (void)stateButtonPressed {
    if ([self.delegate respondsToSelector:@selector(lfx_deviceStateChanged:)]) {
        [self.delegate lfx_deviceStateChanged:self.dataModel];
    }
}

- (void)longPressEventAction {
    if ([self.delegate respondsToSelector:@selector(lfx_cellDeleteButtonPressed:)]) {
        [self.delegate lfx_cellDeleteButtonPressed:self.indexPath.row];
    }
}

#pragma mark - setter
- (void)setDataModel:(MKLFXDeviceModel *)dataModel {
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel || ![_dataModel isKindOfClass:MKLFXDeviceModel.class]) {
        return;
    }
    self.deviceNameLabel.text = SafeStr(_dataModel.deviceName);
    
    if (_dataModel.state == MKLFXDeviceModelStateOffline) {
        //是否在线优先级最高
        self.stateLabel.text = @"Offline";
        self.stateLabel.textColor = UIColorFromRGB(0xcccccc);
        [self.stateButton setImage:LOADICON(@"MokoLifeX", @"MKLFXDeviceListCell", @"lfx_switchUnselectedIcon.png") forState:UIControlStateNormal];
        return;
    }
    
    if (_dataModel.overState != MKLFXDeviceOverState_normal) {
        //设备处于过载、过流、过压状态
        self.stateLabel.textColor = [UIColor redColor];
        [self.stateButton setImage:LOADICON(@"MokoLifeX", @"MKLFXDeviceListCell", @"lfx_switchUnselectedIcon.png") forState:UIControlStateNormal];
        if (_dataModel.overState == MKLFXDeviceOverState_overLoad) {
            //过载
            self.stateLabel.text = @"Overload";
        }else if (_dataModel.overState == MKLFXDeviceOverState_overCurrent) {
            //过流
            self.stateLabel.text = @"Overcurrent";
        }else if (_dataModel.overState == MKLFXDeviceOverState_overVoltage) {
            //过压
            self.stateLabel.text = @"Overvoltage";
        }
        return;
    }
    //正常状态
    self.stateLabel.textColor = (_dataModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0xcccccc);
    if (_dataModel.state == MKLFXDeviceModelStateOn) {
        self.stateLabel.text = @"ON";
    }else if (_dataModel.state == MKLFXDeviceModelStateOff) {
        self.stateLabel.text = @"OFF";
    }
    UIImage *stateIcon = (_dataModel.state == MKLFXDeviceModelStateOn) ? LOADICON(@"MokoLifeX", @"MKLFXDeviceListCell", @"lfx_switchSelectedIcon.png") : LOADICON(@"MokoLifeX", @"MKLFXDeviceListCell", @"lfx_switchUnselectedIcon.png");
    [self.stateButton setImage:stateIcon forState:UIControlStateNormal];
}

#pragma mark - private method
- (void)addLongPressEventAction {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(longPressEventAction)];
    [self.contentView addGestureRecognizer:longPress];
}

#pragma mark - getter
- (UIImageView *)leftIcon {
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
        _leftIcon.image = LOADICON(@"MokoLifeX", @"MKLFXDeviceListCell", @"lfx_deviceListIcon.png");
    }
    return _leftIcon;
}

- (UILabel *)deviceNameLabel {
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
        _deviceNameLabel.font = MKFont(14.f);
        _deviceNameLabel.textColor = DEFAULT_TEXT_COLOR;
    }
    return _deviceNameLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = UIColorFromRGB(0xcccccc);
        _stateLabel.textAlignment = NSTextAlignmentLeft;
        _stateLabel.font = MKFont(12.f);
    }
    return _stateLabel;
}

- (UIImageView *)nextIcon {
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] init];
        _nextIcon.image = LOADICON(@"MokoLifeX", @"MKLFXDeviceListCell", @"mk_lfx_goNextIcon.png");
    }
    return _nextIcon;
}

- (UIButton *)stateButton {
    if (!_stateButton) {
        _stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stateButton addTarget:self
                         action:@selector(stateButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateButton;
}

@end
