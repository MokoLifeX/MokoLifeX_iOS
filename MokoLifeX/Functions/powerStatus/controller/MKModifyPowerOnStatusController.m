//
//  MKModifyPowerOnStatusController.m
//  MokoLifeX
//
//  Created by aa on 2019/8/8.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKModifyPowerOnStatusController.h"

static CGFloat const iconWidth = 13.f;
static CGFloat const iconHeight = 13.f;

@interface MKModifyPowerOnStatusController ()

@property (nonatomic, strong)UIView *offButton;

@property (nonatomic, strong)UIImageView *offIcon;

@property (nonatomic, strong)UIView *onButton;

@property (nonatomic, strong)UIImageView *onIcon;

@property (nonatomic, strong)UIView *revertButton;

@property (nonatomic, strong)UIImageView *revertIcon;

@property (nonatomic, assign)NSInteger currentStatus;

@end

@implementation MKModifyPowerOnStatusController

- (void)dealloc {
    NSLog(@"MKModifyPowerOnStatusController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readStatus];
    // Do any additional setup after loading the view.
}

#pragma mark - event method
- (void)offButtonPressed {
    if (self.currentStatus == 0) {
        return;
    }
    [self configStatus:0];
}

- (void)onButtonPressed {
    if (self.currentStatus == 1) {
        return;
    }
    [self configStatus:1];
}

- (void)revertButtonPressed {
    if (self.currentStatus == 2) {
        return;
    }
    [self configStatus:2];
}

#pragma mark - note
- (void)receiveStatusNotification:(NSNotification *)note {
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_id]) {
        return;
    }
    [[MKHudManager share] hide];
    self.currentStatus = [deviceDic[@"switch_state"] integerValue];
    [self loadStatusIcon];
}

#pragma mark - interface
- (void)configStatus:(NSInteger)current {
    [[MKHudManager share] showHUDWithTitle:@"Waiting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface configDevicePowerOnStatus:current topic:self.deviceModel.subscribedTopic sucBlock:^{
        [[MKHudManager share] hide];
        self.currentStatus = current;
        [self loadStatusIcon];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readStatus {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readDevicePowerOnStatusWithTopic:self.deviceModel.subscribedTopic sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveStatusNotification:)
                                                     name:MKMQTTServerReceivedDevicePowerOnStatusNotification
                                                   object:nil];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)loadStatusIcon {
    if (self.currentStatus == 0) {
        self.offIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
        self.onIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        self.revertIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        return;
    }
    if (self.currentStatus == 1) {
        self.offIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        self.onIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
        self.revertIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        return;
    }
    if (self.currentStatus == 2) {
        self.offIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        self.onIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
        self.revertIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
        return;
    }
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"Modify power on status";
    
    [self.view addSubview:self.offButton];
    [self.view addSubview:self.onButton];
    [self.view addSubview:self.revertButton];
    [self.offButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 15.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.onButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.offButton.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.revertButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.onButton.mas_bottom).mas_offset(15.f);
        make.height.mas_equalTo(35.f);
    }];
}

#pragma mark - setter & getter
- (UIImageView *)offIcon {
    if (!_offIcon) {
        _offIcon = [[UIImageView alloc] init];
        _offIcon.image = LOADIMAGE(@"configServer_ConnectMode_selected", @"png");
    }
    return _offIcon;
}

- (UIView *)offButton {
    if (!_offButton) {
        _offButton = [[UIView alloc] init];
        [_offButton addTapAction:self selector:@selector(offButtonPressed)];
        
        [_offButton addSubview:self.offIcon];
        
        [self.offIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_offButton.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *offLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        offLabel.font = MKFont(12.f);
        offLabel.text = @"Switched off";
        [_offButton addSubview:offLabel];
        [offLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.offIcon.mas_right).mas_offset(3.f);
            make.right.mas_equalTo(-1.f);
            make.centerY.mas_equalTo(_offButton.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _offButton;
}

- (UIImageView *)onIcon {
    if (!_onIcon) {
        _onIcon = [[UIImageView alloc] init];
        _onIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    }
    return _onIcon;
}

- (UIView *)onButton {
    if (!_onButton) {
        _onButton = [[UIView alloc] init];
        [_onButton addTapAction:self selector:@selector(onButtonPressed)];
        
        [_onButton addSubview:self.onIcon];
        
        [self.onIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_onButton.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *onLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        onLabel.font = MKFont(12.f);
        onLabel.text = @"Switched on";
        [_onButton addSubview:onLabel];
        [onLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.onIcon.mas_right).mas_offset(3.f);
            make.right.mas_equalTo(-1.f);
            make.centerY.mas_equalTo(_onButton.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _onButton;
}

- (UIImageView *)revertIcon {
    if (!_revertIcon) {
        _revertIcon = [[UIImageView alloc] init];
        _revertIcon.image = LOADIMAGE(@"configServer_ConnectMode_normal", @"png");
    }
    return _revertIcon;
}

- (UIView *)revertButton {
    if (!_revertButton) {
        _revertButton = [[UIView alloc] init];
        [_revertButton addTapAction:self selector:@selector(revertButtonPressed)];
        
        [_revertButton addSubview:self.revertIcon];
        
        [self.revertIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(iconWidth);
            make.centerY.mas_equalTo(_revertButton.mas_centerY);
            make.height.mas_equalTo(iconHeight);
        }];
        UILabel *revertLabel = [MKConfigServerAdopter configServerDefaultMsgLabel];
        revertLabel.font = MKFont(12.f);
        revertLabel.text = @"Revert to the last status";
        [_revertButton addSubview:revertLabel];
        [revertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.revertIcon.mas_right).mas_offset(3.f);
            make.right.mas_equalTo(-1.f);
            make.centerY.mas_equalTo(_revertButton.mas_centerY);
            make.height.mas_equalTo([MKConfigServerAdopter defaultMsgLabelHeight]);
        }];
    }
    return _revertButton;
}

@end