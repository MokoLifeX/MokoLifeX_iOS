//
//  MKLFXBSwitchStateController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/31.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBSwitchStateController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "NirKxMenu.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCountdownPickerView.h"

#import "MKLFXElectricityController.h"

#import "MKLFXBMQTTManager.h"
#import "MKLFXBMQTTInterface.h"

#import "MKLFXBSwitchViewButton.h"

#import "MKLFXBMoreController.h"
#import "MKLFXBSettingsController.h"
#import "MKLFXBEnergyController.h"

static CGFloat const switchButtonWidth = 200.f;
static CGFloat const switchButtonHeight = 200.f;
static CGFloat const buttonViewWidth = 50.f;
static CGFloat const buttonViewHeight = 50.f;

@interface MKLFXBSwitchStateController ()

@property (nonatomic, strong)UIButton *switchButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UILabel *delayTimeLabel;

@property (nonatomic, strong)MKLFXBSwitchViewButton *powerButton;

@property (nonatomic, strong)MKLFXBSwitchViewButtonModel *powerButtonModel;

@property (nonatomic, strong)MKLFXBSwitchViewButton *timerButton;

@property (nonatomic, strong)MKLFXBSwitchViewButtonModel *timerButtonModel;

@property (nonatomic, strong)MKLFXBSwitchViewButton *energyButton;

@property (nonatomic, strong)MKLFXBSwitchViewButtonModel *energyButtonModel;

/// 是否过载
@property (nonatomic, assign)BOOL isOverload;

/// 过载值
@property (nonatomic, copy)NSString *overloadValue;

@end

@implementation MKLFXBSwitchStateController

- (void)dealloc {
    NSLog(@"MKLFXBSwitchStateController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //返回设备列表页面需要销毁单例
    [MKLFXBMQTTManager singleDealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [MKLFXBMQTTManager shared];
    [self loadSubViews];
    [self configDate];
}

#pragma mark - super method
- (void)rightButtonMethod {
    KxMenuItem *moreItem = [KxMenuItem menuItem:@"More"
                                          image:nil
                                         target:self
                                         action:@selector(moreItemMethod)];
    KxMenuItem *settingsItem = [KxMenuItem menuItem:@"Settings"
                                              image:nil
                                             target:self
                                             action:@selector(settingsItemMethod)];
    
    //menuItem字体颜色
    Color offTextColor = {
        0,
        0,
        0
    };
    Color onTextColor = {
        1,
        1,
        1
    };
    //菜单的底色
    Color offMenuBackgroundColor = {
        1,
        1,
        1,
    };
    Color onMenuBackgroundColor = {
        69.f / 255.f,
        154.f / 255.f,
        197.0 / 255.f,
    };
    
    OptionalConfiguration configuration = {
        9,//指示箭头大小
        7,//MenuItem左右边距
        9,//MenuItem上下边距
        7,//MenuItemImage与MenuItemTitle的间距
        6.5,//菜单圆角半径
        NO,//是否添加覆盖在原View上的半透明遮罩
        NO,//是否添加菜单阴影
        YES,//是否设置分割线
        NO,//是否在分割线两侧留下Insets
        (self.deviceModel.state == MKLFXDeviceModelStateOn ? onTextColor : offTextColor),//menuItem字体颜色
        (self.deviceModel.state == MKLFXDeviceModelStateOn ? onMenuBackgroundColor : offMenuBackgroundColor)//菜单的底色
    };
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(kViewWidth - 62.f, 8, 50.f, 60.f)
                 menuItems:@[moreItem,settingsItem]
               withOptions:configuration];
}

#pragma mark - notes
- (void)receiveDeviceOffline:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"deviceID"]) || ![userInfo[@"deviceID"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    //如果存在弹窗，则消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfxb_dismissAlert" object:nil];
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

- (void)deviceOverloadStatusChanged:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1005) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    self.isOverload = ([userInfo[@"data"][@"overload_state"] integerValue] == 1);
    self.overloadValue = [NSString stringWithFormat:@"%ld",(long)[userInfo[@"data"][@"overload_value"] integerValue]];
    [self configView];
}

- (void)deviceLoadStatusChanged:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    if ([userInfo[@"data"][@"load"] integerValue] == 1) {
        [self.view showCentralToast:@"Load Insertion"];
    }
}

- (void)receiveDeviceNameChanged:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user) || !ValidStr(user[@"macAddress"]) || ![self.deviceModel.macAddress isEqualToString:user[@"macAddress"]]) {
        return;
    }
    self.defaultTitle = user[@"deviceName"];
}

#pragma mark - event method
- (void)moreItemMethod {
    MKLFXBMoreController *vc = [[MKLFXBMoreController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settingsItemMethod {
    MKLFXBSettingsController *vc = [[MKLFXBSettingsController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    if (self.isOverload) {
        [self.view showCentralToast:@"Device is overload"];
        return;
    }
    BOOL isOn = (self.deviceModel.state == MKLFXDeviceModelStateOn);
    [MKLFXBMQTTInterface lfxb_configDeviceSwitchState:!isOn
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
    MKLFXElectricityController *vc = [[MKLFXElectricityController alloc] init];
    vc.deviceModel = self.deviceModel;
    vc.electricityNotificationName = MKLFXBReceiveElectricityNotification;
    vc.voltageCoffe = 1.f;
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
    MKLFXBEnergyController *vc = [[MKLFXBEnergyController alloc] init];
    vc.deviceModel = self.deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - interface
- (void)configDate {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_setDeviceDate:[NSDate date]
                                   deviceID:self.deviceModel.deviceID
                                      topic:[self.deviceModel currentSubscribedTopic]
                                   sucBlock:^{
        [self readDataFromDevice];
    }
                                failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
}

- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_readOverloadValueWithDeviceID:self.deviceModel.deviceID
                                                      topic:[self.deviceModel currentSubscribedTopic]
                                                   sucBlock:^{
        [self addNotifications];
        [self startReadTimer];
    }
                                                failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
}

- (void)setDelay:(NSString *)hour delayMin:(NSString *)min{
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_setDeviceDelayHour:[hour integerValue]
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
    if (self.isOverload) {
        //是否过载的优先级最高
        [self deviceOverloadUI];
        return;
    }
    
    self.custom_naviBarColor = (self.deviceModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x303a4b);
    [self.view setBackgroundColor:((self.deviceModel.state == MKLFXDeviceModelStateOn) ? UIColorFromRGB(0xf2f2f2) : UIColorFromRGB(0x303a4b))];
    UIImage *switchIcon = ((self.deviceModel.state == MKLFXDeviceModelStateOn) ? LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_switchButtonOn.png") : LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_switchButtonOff.png"));
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

- (void)deviceOverloadUI {
    self.custom_naviBarColor = UIColorFromRGB(0x303a4b);
    [self.view setBackgroundColor:UIColorFromRGB(0x303a4b)];
    [self.switchButton setImage:LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_switchButtonOff.png") forState:UIControlStateNormal];
    self.stateLabel.textColor = UIColorFromRGB(0x808080);
    self.stateLabel.text = [NSString stringWithFormat:@"Socket is overload,overload value %@W",self.overloadValue];
    [self.delayTimeLabel setHidden:YES];
    
    [self updateButtonView:NO];
}

- (void)updateButtonView:(BOOL)isOn {
    UIColor *msgColor = (isOn ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    self.timerButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_timerOn.png") : LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_timerOff.png"));
    self.timerButtonModel.msgColor = msgColor;
    self.timerButton.dataModel = self.timerButtonModel;
    
    self.powerButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_powerOn.png") : LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_powerOff.png"));
    self.powerButtonModel.msgColor = msgColor;
    self.powerButton.dataModel = self.powerButtonModel;
    
    self.energyButtonModel.icon = (isOn ? LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_energyOn.png") : LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_energyOff.png"));
    self.energyButtonModel.msgColor = msgColor;
    self.energyButton.dataModel = self.energyButtonModel;
}

#pragma mark - Notes
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOffline:)
                                                 name:MKLFXDeviceModelOfflineNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceStateChanged:)
                                                 name:MKLFXBReceiveSwitchStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delayTimeNotification:)
                                                 name:MKLFXBReceiveDelayTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOverloadStatusChanged:)
                                                 name:MKLFXBReceiveOverloadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceLoadStatusChanged:)
                                                 name:MKLFXBLoadStatusChangedNotification
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
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXBSwitchStateController", @"lfx_moreIcon.png") forState:UIControlStateNormal];
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
        make.bottom.mas_equalTo(-VirtualHomeHeight - 10.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.powerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 10.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.energyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 10.f);
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

- (MKLFXBSwitchViewButton *)powerButton {
    if (!_powerButton) {
        _powerButton = [[MKLFXBSwitchViewButton alloc] init];
        [_powerButton addTarget:self
                         action:@selector(powerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _powerButton;
}

- (MKLFXBSwitchViewButtonModel *)powerButtonModel {
    if (!_powerButtonModel) {
        _powerButtonModel = [[MKLFXBSwitchViewButtonModel alloc] init];
        _powerButtonModel.msg = @"Power";
    }
    return _powerButtonModel;
}

- (MKLFXBSwitchViewButton *)timerButton {
    if (!_timerButton) {
        _timerButton = [[MKLFXBSwitchViewButton alloc] init];
        [_timerButton addTarget:self
                         action:@selector(timerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _timerButton;
}

- (MKLFXBSwitchViewButtonModel *)timerButtonModel {
    if (!_timerButtonModel) {
        _timerButtonModel = [[MKLFXBSwitchViewButtonModel alloc] init];
        _timerButtonModel.msg = @"Timer";
    }
    return _timerButtonModel;
}

- (MKLFXBSwitchViewButton *)energyButton {
    if (!_energyButton) {
        _energyButton = [[MKLFXBSwitchViewButton alloc] init];
        [_energyButton addTarget:self
                          action:@selector(energyButtonPressed)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _energyButton;
}

- (MKLFXBSwitchViewButtonModel *)energyButtonModel {
    if (!_energyButtonModel) {
        _energyButtonModel = [[MKLFXBSwitchViewButtonModel alloc] init];
        _energyButtonModel.msg = @"Energy";
    }
    return _energyButtonModel;
}

@end
