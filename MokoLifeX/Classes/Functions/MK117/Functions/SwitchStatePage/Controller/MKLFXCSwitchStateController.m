//
//  MKLFXCSwitchStateController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/8.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSwitchStateController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKAlertController.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCountdownPickerView.h"

#import "MKLFXCMQTTManager.h"
#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"

#import "MKLFXCSwitchViewButton.h"

#import "MKLFXCElectricityController.h"
#import "MKLFXCSettingsController.h"
#import "MKLFXCEnergyController.h"

static CGFloat const switchButtonWidth = 200.f;
static CGFloat const switchButtonHeight = 200.f;
static CGFloat const buttonViewWidth = 70.f;
static CGFloat const buttonViewHeight = 50.f;

static NSString *const clearOverStateMsg = @"Please confirm your load is within the protection threshold, otherwise, it will enter protection state again!";

@interface MKLFXCSwitchStateController ()

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UILabel *delayTimeLabel;

@property (nonatomic, strong)MKLFXCSwitchViewButton *powerButton;

@property (nonatomic, strong)MKLFXCSwitchViewButtonModel *powerButtonModel;

@property (nonatomic, strong)MKLFXCSwitchViewButton *timerButton;

@property (nonatomic, strong)MKLFXCSwitchViewButtonModel *timerButtonModel;

@property (nonatomic, strong)MKLFXCSwitchViewButton *energyButton;

@property (nonatomic, strong)MKLFXCSwitchViewButtonModel *energyButtonModel;

@property (nonatomic, assign)BOOL readState;

@end

@implementation MKLFXCSwitchStateController

- (void)dealloc {
    NSLog(@"MKLFXCSwitchStateController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //返回设备列表页面需要销毁单例
    [MKLFXCMQTTManager singleDealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化
    [MKLFXCMQTTManager shared];
    [self loadSubViews];
    [self configView];
    [self readDataFromDevice];
    [self addNotifications];
}

#pragma mark - super method
- (void)rightButtonMethod {
    MKLFXCSettingsController *vc = [[MKLFXCSettingsController alloc] init];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfxc_dismissAlert" object:nil];
    self.deviceModel.state = MKLFXDeviceModelStateOffline;
    [self.view showCentralToast:@"Device offline!"];
    [self performSelector:@selector(gotoRootController) withObject:nil afterDelay:0.5f];
}

- (void)receiveDeviceStateChanged:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (self.readTimeout || !ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1001) {
        return;
    }
    if (self.readState) {
        self.readState = NO;
        [[MKHudManager share] hide];
        [self cancelTimer];
    }
    [self receiveSwitchStateData:userInfo];
}

- (void)receiveOverload:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (self.readTimeout || !ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1105) {
        return;
    }
    BOOL isOver = ([userInfo[@"data"][@"state"] integerValue] == 1);
    [self receiveOverProtectionState:isOver method:@selector(showOverloadAlert)];
}

- (void)receiveOverCurrent:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (self.readTimeout || !ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1113) {
        return;
    }
    BOOL isOver = ([userInfo[@"data"][@"state"] integerValue] == 1);
    [self receiveOverProtectionState:isOver method:@selector(showOverCurrentAlert)];
}

- (void)receiveOverVoltage:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (self.readTimeout || !ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1109) {
        return;
    }
    BOOL isOver = ([userInfo[@"data"][@"state"] integerValue] == 1);
    [self receiveOverProtectionState:isOver method:@selector(showOverVoltageAlert)];
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
    NSString *stateMsg = [NSString stringWithFormat:@"Device will turn %@ after %@", userInfo[@"data"][@"switch_state"], timeMsg];
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
    [MKLFXCMQTTInterface lfxc_configDeviceSwitchState:!isOn
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

- (void)powerButtonPressed {
    MKLFXCElectricityController *vc = [[MKLFXCElectricityController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
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

- (void)energyButtonPressed {
    MKLFXCEnergyController *vc = [[MKLFXCEnergyController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    self.readState = YES;
    [MKLFXCMQTTInterface lfxc_readDeviceSwitchStateWithDeviceID:self.deviceModel.deviceID
                                                          topic:[self.deviceModel currentSubscribedTopic]
                                                       sucBlock:^{
        [self startReadTimer];
    }
                                                    failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)setDelay:(NSString *)hour delayMin:(NSString *)min{
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_setDeviceDelayHour:[hour integerValue]
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

#pragma mark - Private method
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOffline:)
                                                 name:MKLFXDeviceModelOfflineNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceStateChanged:)
                                                 name:MKLFXCReceiveSwitchStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOverload:)
                                                 name:MKLFXCReceiveOverLoadStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOverCurrent:)
                                                 name:MKLFXCReceiveOverCurrentStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOverVoltage:)
                                                 name:MKLFXCReceiveOverVoltageStatusNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delayTimeNotification:)
                                                 name:MKLFXCReceiveDelayTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceNameChanged:)
                                                 name:@"mk_lfx_deviceNameChangedNotification"
                                               object:nil];
}

- (void)gotoRootController {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)receiveSwitchStateData:(NSDictionary *)userInfo {
    self.deviceModel.state = ([userInfo[@"data"][@"switch_state"] isEqualToString:@"on"] ? MKLFXDeviceModelStateOn : MKLFXDeviceModelStateOff);
    MKLFXDeviceOverState overState = MKLFXDeviceOverState_normal;
    if (ValidNum(userInfo[@"data"][@"overload_state"]) && [userInfo[@"data"][@"overload_state"] integerValue] == 1) {
        overState = MKLFXDeviceOverState_overLoad;
    }else if (ValidNum(userInfo[@"data"][@"overcurrent_state"]) && [userInfo[@"data"][@"overcurrent_state"] integerValue] == 1) {
        overState = MKLFXDeviceOverState_overCurrent;
    }else if (ValidNum(userInfo[@"data"][@"overvoltage_state"]) && [userInfo[@"data"][@"overvoltage_state"] integerValue] == 1) {
        overState = MKLFXDeviceOverState_overVoltage;
    }
    self.deviceModel.overState = overState;
    [self configView];
    [self.delayTimeLabel setHidden:YES];
    
    if (overState == MKLFXDeviceOverState_normal) {
        return;
    }
    //抛出通知，设备处于过载/过压/过流状态，强制让下级页面返回本页面
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfxc_deviceOverProtectionThresholdNotification"
                                                        object:nil
                                                      userInfo:@{@"deviceID":self.deviceModel.deviceID}];
    if (overState == MKLFXDeviceOverState_overLoad) {
        //过载
        [self performSelector:@selector(showOverloadAlert) withObject:nil afterDelay:.5f];
        return;
    }
    if (overState == MKLFXDeviceOverState_overCurrent) {
        //过流
        [self performSelector:@selector(showOverCurrentAlert) withObject:nil afterDelay:.5f];
        return;
    }
    if (overState == MKLFXDeviceOverState_overVoltage) {
        //过压
        [self performSelector:@selector(showOverVoltageAlert) withObject:nil afterDelay:.5f];
        return;
    }
}

- (void)receiveOverProtectionState:(BOOL)isOver method:(SEL)method {
    if (isOver) {
        //过压
        //抛出通知，设备处于过载/过压/过流状态，强制让下级页面返回本页面
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfxc_deviceOverProtectionThresholdNotification"
                                                            object:nil
                                                          userInfo:@{@"deviceID":self.deviceModel.deviceID}];
        [self performSelector:method withObject:nil afterDelay:0.5f];
        return;
    }
    //未过压
    //如果存在弹窗，则让弹窗消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfxc_dismissAlert" object:nil];
    self.deviceModel.overState = MKLFXDeviceOverState_normal;
    [self configView];
}

#pragma mark - 过载
- (void)showOverloadAlert {
    NSString *msg = @"Socket is overload, do you want to clear the protection state?";
    @weakify(self);
    [self showAlertWithMsg:msg confirmBlock:^{
        @strongify(self);
        [self performSelector:@selector(showOverloadConfirmAlert) withObject:nil afterDelay:0.3];
    }];
}

- (void)showOverloadConfirmAlert {
    @weakify(self);
    [self showAlertWithMsg:clearOverStateMsg confirmBlock:^{
        @strongify(self);
        [self clearOverloadStatus];
    }];
}

- (void)clearOverloadStatus {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_clearOverLoadStatusWithDeviceID:self.deviceModel.deviceID
                                                        topic:[self.deviceModel currentSubscribedTopic]
                                                     sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    }
                                                  failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 过流
- (void)showOverCurrentAlert {
    NSString *msg = @"Socket is overcurrent, do you want to clear the protection state?";
    @weakify(self);
    [self showAlertWithMsg:msg confirmBlock:^{
        @strongify(self);
        [self performSelector:@selector(showOverCurrentConfirmAlert) withObject:nil afterDelay:0.3];
    }];
}

- (void)showOverCurrentConfirmAlert {
    @weakify(self);
    [self showAlertWithMsg:clearOverStateMsg confirmBlock:^{
        @strongify(self);
        [self clearOverCurrentStatus];
    }];
}

- (void)clearOverCurrentStatus {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_clearOverCurrentStatusWithDeviceID:self.deviceModel.deviceID
                                                           topic:[self.deviceModel currentSubscribedTopic]
                                                        sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    }
                                                     failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 过压
- (void)showOverVoltageAlert {
    NSString *msg = @"Socket is overvoltage, do you want to clear the protection state?";
    @weakify(self);
    [self showAlertWithMsg:msg confirmBlock:^{
        @strongify(self);
        [self performSelector:@selector(showOverVoltageConfirmAlert) withObject:nil afterDelay:0.3];
    }];
}

- (void)showOverVoltageConfirmAlert {
    @weakify(self);
    [self showAlertWithMsg:clearOverStateMsg confirmBlock:^{
        @strongify(self);
        [self clearOverVoltageStatus];
    }];
}

- (void)clearOverVoltageStatus {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_clearOverVoltageStatusWithDeviceID:self.deviceModel.deviceID
                                                           topic:[self.deviceModel currentSubscribedTopic]
                                                        sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    }
                                                     failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark -
- (void)showAlertWithMsg:(NSString *)msg confirmBlock:(void (^)(void))block {
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Warning"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self gotoRootController];
    }];
    [alertView addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (block) {
            block();
        }
    }];
    [alertView addAction:moreAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - UI method
- (void)configView{
    BOOL stateOn = NO;
    if (self.deviceModel.overState == MKLFXDeviceOverState_normal && self.deviceModel.state == MKLFXDeviceModelStateOn) {
        //未处于过载/过流/过压状态下，开关状态是打开，才会显示带色彩的UI
        stateOn = YES;
    }
    self.custom_naviBarColor = (stateOn ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x303a4b));
    [self.view setBackgroundColor:(stateOn ? UIColorFromRGB(0xf2f2f2) : UIColorFromRGB(0x303a4b))];
    UIImage *switchIcon = (stateOn ? LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_switchButtonOn.png") : LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_switchButtonOff.png"));
    [self.switchButton setImage:switchIcon forState:UIControlStateNormal];
    self.stateLabel.textColor = (stateOn ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    if (self.deviceModel.overState == MKLFXDeviceOverState_normal) {
        self.stateLabel.text = ((self.deviceModel.state == MKLFXDeviceModelStateOn) ? @"Socket is on" : @"Socket is off");
    }else if (self.deviceModel.overState == MKLFXDeviceOverState_overLoad) {
        //过载
        self.stateLabel.text = @"Socket is overload";
    }else if (self.deviceModel.overState == MKLFXDeviceOverState_overCurrent) {
        //过流
        self.stateLabel.text = @"Socket is overcurrent";
    }else if (self.deviceModel.overState == MKLFXDeviceOverState_overVoltage) {
        //过压
        self.stateLabel.text = @"Socket is overvoltage";
    }
    
    [self updateButtonView:stateOn];
}

- (void)updateButtonView:(BOOL)isOn {
    UIColor *msgColor = (isOn ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    self.timerButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_timerOn.png") : LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_timerOff.png"));
    self.timerButtonModel.msgColor = msgColor;
    self.timerButton.dataModel = self.timerButtonModel;
    
    self.powerButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_powerOn.png") : LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_powerOff.png"));
    self.powerButtonModel.msgColor = msgColor;
    self.powerButton.dataModel = self.powerButtonModel;
    
    self.energyButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_energyOn.png") : LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_energyOff.png"));
    self.energyButtonModel.msgColor = msgColor;
    self.energyButton.dataModel = self.energyButtonModel;
}

- (void)loadSubViews {
    self.defaultTitle = self.deviceModel.deviceName;
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCSwitchStateController", @"lfx_moreIcon.png") forState:UIControlStateNormal];
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
    [self.view addSubview:self.powerButton];
    [self.view addSubview:self.timerButton];
    [self.view addSubview:self.energyButton];
    [self.timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 20.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.powerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 20.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.energyButton mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (MKLFXCSwitchViewButton *)powerButton {
    if (!_powerButton) {
        _powerButton = [[MKLFXCSwitchViewButton alloc] init];
        [_powerButton addTarget:self
                         action:@selector(powerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _powerButton;
}

- (MKLFXCSwitchViewButtonModel *)powerButtonModel {
    if (!_powerButtonModel) {
        _powerButtonModel = [[MKLFXCSwitchViewButtonModel alloc] init];
        _powerButtonModel.msg = @"Power";
    }
    return _powerButtonModel;
}

- (MKLFXCSwitchViewButton *)timerButton {
    if (!_timerButton) {
        _timerButton = [[MKLFXCSwitchViewButton alloc] init];
        [_timerButton addTarget:self
                         action:@selector(timerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _timerButton;
}

- (MKLFXCSwitchViewButtonModel *)timerButtonModel {
    if (!_timerButtonModel) {
        _timerButtonModel = [[MKLFXCSwitchViewButtonModel alloc] init];
        _timerButtonModel.msg = @"Timer";
    }
    return _timerButtonModel;
}

- (MKLFXCSwitchViewButton *)energyButton {
    if (!_energyButton) {
        _energyButton = [[MKLFXCSwitchViewButton alloc] init];
        [_energyButton addTarget:self
                          action:@selector(energyButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _energyButton;
}

- (MKLFXCSwitchViewButtonModel *)energyButtonModel {
    if (!_energyButtonModel) {
        _energyButtonModel = [[MKLFXCSwitchViewButtonModel alloc] init];
        _energyButtonModel.msg = @"Energy";
    }
    return _energyButtonModel;
}

@end
