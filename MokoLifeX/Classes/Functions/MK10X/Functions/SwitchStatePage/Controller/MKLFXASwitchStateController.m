//
//  MKLFXASwitchStateController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXASwitchStateController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCountdownPickerView.h"

#import "MKLFXElectricityController.h"

#import "MKLFXAMQTTManager.h"
#import "MKLFXAMQTTInterface.h"

#import "MKLFXASwitchViewButton.h"

#import "MKLFXAMoreController.h"

static CGFloat const switchButtonWidth = 200.f;
static CGFloat const switchButtonHeight = 200.f;
static CGFloat const buttonViewWidth = 70.f;
static CGFloat const buttonViewHeight = 50.f;

@interface MKLFXASwitchStateController ()

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UILabel *delayTimeLabel;

@property (nonatomic, strong)MKLFXASwitchViewButton *scheduleButton;

@property (nonatomic, strong)MKLFXASwitchViewButtonModel *scheduleButtonModel;

@property (nonatomic, strong)MKLFXASwitchViewButton *timerButton;

@property (nonatomic, strong)MKLFXASwitchViewButtonModel *timerButtonModel;

@property (nonatomic, strong)MKLFXASwitchViewButton *statisticsButton;

@property (nonatomic, strong)MKLFXASwitchViewButtonModel *statisticsButtonModel;

@end

@implementation MKLFXASwitchStateController

- (void)dealloc {
    NSLog(@"MKLFXASwitchStateController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //返回设备列表页面需要销毁单例
    [MKLFXAMQTTManager singleDealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    [MKLFXAMQTTManager shared];
    [self loadSubViews];
    [self configView];
    [self addNotifications];
}

#pragma mark - super method
- (void)rightButtonMethod {
    MKLFXAMoreController *vc = [[MKLFXAMoreController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - notes
- (void)receiveDeviceOffline:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"deviceID"]) || ![userInfo[@"deviceID"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    //如果存在弹窗，则让弹窗消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfxa_dismissAlert" object:nil];
    self.deviceModel.state = MKLFXDeviceModelStateOffline;
    [self.view showCentralToast:@"Device offline!"];
    [self performSelector:@selector(gotoRootController) withObject:nil afterDelay:0.5f];
}

- (void)receiveDeviceStateChanged:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    self.deviceModel.state = ([userInfo[@"data"][@"switch_state"] isEqualToString:@"on"] ? MKLFXDeviceModelStateOn : MKLFXDeviceModelStateOff);
    [self configView];
    [self.delayTimeLabel setHidden:YES];
}

- (void)delayTimeNotification:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    NSString *timeMsg = [NSString stringWithFormat:@"%@:%@:%@",
                         userInfo[@"data"][@"delay_hour"],
                         userInfo[@"data"][@"delay_minute"],
                         userInfo[@"data"][@"delay_second"]];
    //倒计时结束0:0:0
    [self.delayTimeLabel setHidden:[timeMsg isEqualToString:@"0:0:0"]];
    NSString *stateMsg = [NSString stringWithFormat:@"%@ after %@", userInfo[@"data"][@"switch_state"], timeMsg];
    self.delayTimeLabel.text = stateMsg;
    self.delayTimeLabel.textColor = (self.deviceModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080);
}

- (void)receiveDeviceNameChanged:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user) || !ValidStr(user[@"macAddress"]) || ![self.deviceModel.macAddress isEqualToString:user[@"macAddress"]]) {
        return;
    }
    self.defaultTitle = user[@"deviceName"];
}

#pragma mark - event method

- (void)switchButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    BOOL isOn = (self.deviceModel.state == MKLFXDeviceModelStateOn);
    [MKLFXAMQTTInterface lfxa_configDeviceSwitchState:!isOn
                                             deviceID:self.deviceModel.deviceID
                                                topic:[self.deviceModel currentSubscribedTopic]
                                             sucBlock:^{
        [[MKHudManager share] hide];
    }
                                          failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)scheduleButtonPressed {
    [self.view showCentralToast:@"The timing function needs to be improved."];
}

- (void)timerButtonPressed {
    BOOL isOn = (self.deviceModel.state == MKLFXDeviceModelStateOn);
    MKLFXCountdownPickerViewModel *timeModel = [[MKLFXCountdownPickerViewModel alloc] init];
    timeModel.hour = @"0";
    timeModel.minutes = @"0";
    timeModel.titleMsg = (isOn ? @"Countdown timer(off)" : @"Countdown timer(on)");
    MKLFXCountdownPickerView *pickView = [[MKLFXCountdownPickerView alloc] init];
    pickView.timeModel = timeModel;
    @weakify(self);
    [pickView showTimePickViewBlock:^(MKLFXCountdownPickerViewModel *timeModel) {
        @strongify(self);
        [self setDelay:timeModel.hour delayMin:timeModel.minutes];
    }];
}

- (void)statisticsButtonPressed {
    if (![self.deviceModel.deviceType isEqualToString:@"1"]) {
        [self.view showCentralToast:@"The device does not have this function."];
        return;
    }
    MKLFXElectricityController *vc = [[MKLFXElectricityController alloc] init];
    vc.deviceModel = self.deviceModel;
    vc.electricityNotificationName = MKLFXAReceiveElectricityNotification;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - interface

- (void)setDelay:(NSString *)hour delayMin:(NSString *)min{
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKLFXAMQTTInterface lfxa_setDeviceDelayHour:[hour integerValue]
                                        delayMin:[min integerValue]
                                        deviceID:self.deviceModel.deviceID
                                           topic:[self.deviceModel currentSubscribedTopic]
                                        sucBlock:^{
        [[MKHudManager share] hide];
    }
                                     failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI method
- (void)configView{
    self.custom_naviBarColor = (self.deviceModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x303a4b);
    [self.view setBackgroundColor:((self.deviceModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0xf2f2f2) : UIColorFromRGB(0x303a4b))];
    UIImage *switchIcon = ((self.deviceModel.state == MKLFXDeviceModelStateOn) ? LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_switchButtonOn.png") : LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_switchButtonOff.png"));
    [self.switchButton setImage:switchIcon forState:UIControlStateNormal];
    self.stateLabel.textColor = ((self.deviceModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    NSString *textMsg = @"Socket is off";
    if (self.deviceModel.state == MKLFXDeviceModelStateOffline) {
        textMsg = @"Socket is offline";
    }else if (self.deviceModel.state == MKLFXDeviceModelStateOn){
        textMsg = @"Socket is on";
    }
    self.stateLabel.text = textMsg;
    
    if (self.deviceModel.state == MKLFXDeviceModelStateOffline) {
        [self.delayTimeLabel setHidden:YES];
    }
    
    [self updateButtonView:(self.deviceModel.state == MKLFXDeviceModelStateOn)];
}

- (void)updateButtonView:(BOOL)isOn {
    UIColor *msgColor = (isOn ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    self.timerButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_timerOn.png") : LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_timerOff.png"));
    self.timerButtonModel.msgColor = msgColor;
    self.timerButton.dataModel = self.timerButtonModel;
    
    self.scheduleButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_scheduleOn.png") : LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_scheduleOff.png"));
    self.scheduleButtonModel.msgColor = msgColor;
    self.scheduleButton.dataModel = self.scheduleButtonModel;
    
    self.statisticsButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_statisticsOn.png") : LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_statisticsOff.png"));
    self.statisticsButtonModel.msgColor = msgColor;
    self.statisticsButton.dataModel = self.statisticsButtonModel;
}

#pragma mark - Notes
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOffline:)
                                                 name:MKLFXDeviceModelOfflineNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceStateChanged:)
                                                 name:MKLFXAReceiveSwitchStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delayTimeNotification:)
                                                 name:MKLFXAReceiveDelayTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceNameChanged:)
                                                 name:@"mk_lfx_deviceNameChangedNotification"
                                               object:nil];
}

#pragma mark -
- (void)gotoRootController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = self.deviceModel.deviceName;
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXASwitchStateController", @"lfx_moreIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.switchButton];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(200.f);
        make.top.mas_equalTo(176.f);
        make.height.mas_equalTo(200.f);
    }];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.delayTimeLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.f);
        make.right.mas_equalTo(-20.f);
        make.top.mas_equalTo(self.switchButton.mas_bottom).mas_offset(45.f);
        make.height.mas_equalTo(3 * MKFont(15.f).lineHeight);
    }];
    [self.delayTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.f);
        make.right.mas_equalTo(-20.f);
        make.top.mas_equalTo(self.stateLabel.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.view addSubview:self.scheduleButton];
    [self.view addSubview:self.timerButton];
    [self.view addSubview:self.statisticsButton];
    [self.scheduleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 20.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 20.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.statisticsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 20.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
}

#pragma mark - getter
- (UIButton *)switchButton {
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_switchButton addTarget:self
                          action:@selector(switchButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (UILabel *)stateLabel{
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = UIColorFromRGB(0x0188cc);
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.font = MKFont(15.f);
        _stateLabel.text = @"Socket is on";
        _stateLabel.numberOfLines = 0;
    }
    return _stateLabel;
}

- (UILabel *)delayTimeLabel{
    if (!_delayTimeLabel) {
        _delayTimeLabel = [[UILabel alloc] init];
        _delayTimeLabel.textColor = UIColorFromRGB(0x0188cc);
        _delayTimeLabel.textAlignment = NSTextAlignmentCenter;
        _delayTimeLabel.font = MKFont(15.f);
    }
    return _delayTimeLabel;
}

- (MKLFXASwitchViewButton *)scheduleButton {
    if (!_scheduleButton) {
        _scheduleButton = [[MKLFXASwitchViewButton alloc] init];
        [_scheduleButton addTarget:self
                         action:@selector(scheduleButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _scheduleButton;
}

- (MKLFXASwitchViewButtonModel *)scheduleButtonModel {
    if (!_scheduleButtonModel) {
        _scheduleButtonModel = [[MKLFXASwitchViewButtonModel alloc] init];
        _scheduleButtonModel.msg = @"Schedule";
    }
    return _scheduleButtonModel;
}

- (MKLFXASwitchViewButton *)timerButton {
    if (!_timerButton) {
        _timerButton = [[MKLFXASwitchViewButton alloc] init];
        [_timerButton addTarget:self
                         action:@selector(timerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _timerButton;
}

- (MKLFXASwitchViewButtonModel *)timerButtonModel {
    if (!_timerButtonModel) {
        _timerButtonModel = [[MKLFXASwitchViewButtonModel alloc] init];
        _timerButtonModel.msg = @"Timer";
    }
    return _timerButtonModel;
}

- (MKLFXASwitchViewButton *)statisticsButton {
    if (!_statisticsButton) {
        _statisticsButton = [[MKLFXASwitchViewButton alloc] init];
        [_statisticsButton addTarget:self
                          action:@selector(statisticsButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _statisticsButton;
}

- (MKLFXASwitchViewButtonModel *)statisticsButtonModel {
    if (!_statisticsButtonModel) {
        _statisticsButtonModel = [[MKLFXASwitchViewButtonModel alloc] init];
        _statisticsButtonModel.msg = @"Statistics";
    }
    return _statisticsButtonModel;
}

@end
