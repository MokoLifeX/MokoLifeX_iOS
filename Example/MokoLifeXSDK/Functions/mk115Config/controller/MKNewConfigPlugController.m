//
//  MKNewConfigPlugController.m
//  MokoLifeX
//
//  Created by aa on 2020/6/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKNewConfigPlugController.h"
#import "MKConfigDeviceButtonView.h"
#import "MKConfigDeviceButtonModel.h"
#import "MKDeviceInfoController.h"
#import "MKConfigDeviceTimePickerView.h"
#import "MKElectricityController.h"
#import "MKEnergyController.h"
#import "MKSettingsController.h"

#import "NirKxMenu.h"

#import "MKDeviceDataBaseManager.h"

static CGFloat const switchButtonWidth = 200.f;
static CGFloat const switchButtonHeight = 200.f;
static CGFloat const buttonViewWidth = 50.f;
static CGFloat const buttonViewHeight = 50.f;

@interface MKNewConfigPlugController ()<MKDeviceModelDelegate, MKDeviceModelManagerDelegate>

@property (nonatomic, strong)UIImageView *switchButton;

@property (nonatomic, strong)UILabel *stateLabel;

@property (nonatomic, strong)UILabel *delayTimeLabel;

@property (nonatomic, strong)UIView *bottomView;

@property (nonatomic, strong)MKConfigDeviceButtonView *powerButton;

@property (nonatomic, strong)MKConfigDeviceButtonView *timerButton;

@property (nonatomic, strong)MKConfigDeviceButtonView *energyButton;

@property (nonatomic, strong)NSMutableArray *dataList;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

/// 是否过载
@property (nonatomic, assign)BOOL isOverload;

/// 过载值
@property (nonatomic, copy)NSString *overloadValue;

@end

@implementation MKNewConfigPlugController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKNewConfigPlugController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [MKDeviceModelManager.shared clearManagementModel];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self readDeviceName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadDataList];
    [self configView];
    if (MKDeviceModelManager.shared.deviceModel.plugState != MKSmartPlugOffline) {
        //离线状态进来不处理
        [self readOverloadStatus];
    }else {
        [self addNotifications];
    }
    MKDeviceModelManager.shared.delegate = self;
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法

- (void)rightButtonMethod{
    KxMenuItem *moreItem = [KxMenuItem menuItem:@"More"
                                          image:nil
                                         target:self
                                         action:@selector(moreItemMethod)];
    KxMenuItem *settingsItem = [KxMenuItem menuItem:@"Settings"
                                              image:[UIImage imageWithColor:[UIColor redColor]]
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
        (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn ? onTextColor : offTextColor),//menuItem字体颜色
        (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn ? onMenuBackgroundColor : offMenuBackgroundColor)//菜单的底色
    };
    
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(kScreenWidth - 62.f, 8, 50.f, 60.f)
                 menuItems:@[moreItem,settingsItem]
               withOptions:configuration];
}

#pragma mark - MKDeviceModelManagerDelegate
- (void)currentDeviceModelStateChanged:(MKSmartPlugState)plugState {
    self.isOverload = MKDeviceModelManager.shared.deviceModel.isOverload;
    [self configView];
    [self.delayTimeLabel setHidden:YES];
}

#pragma mark - 通知处理

- (void)delayTimeNotification:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    [MKDeviceModelManager.shared.deviceModel resetTimerCounter];
    NSString *timeMsg = [NSString stringWithFormat:@"%@:%@:%@",
                         deviceDic[@"delay_hour"],
                         deviceDic[@"delay_minute"],
                         deviceDic[@"delay_second"]];
    //倒计时结束0:0:0
    [self.delayTimeLabel setHidden:[timeMsg isEqualToString:@"0:0:0"]];
    NSString *stateMsg = [NSString stringWithFormat:@"%@ after %@", deviceDic[@"switch_state"], timeMsg];
    self.delayTimeLabel.text = stateMsg;
    self.delayTimeLabel.textColor = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080);
}

- (void)deviceOverloadStatusChanged:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    self.readTimeout = NO;
    [MKDeviceModelManager.shared.deviceModel resetTimerCounter];
    self.isOverload = ([deviceDic[@"overload_state"] integerValue] == 1);
    self.overloadValue = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"overload_value"] integerValue]];
    [self configView];
}

- (void)deviceLoadStatusChanged:(NSNotification *)note {
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    if ([deviceDic[@"load"] integerValue] == 1) {
        [self.view showCentralToast:@"Load Insertion"];
    }
}

#pragma mark - event method
- (void)moreItemMethod {
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)settingsItemMethod {
    if (![self canClickEnable]) {
        return;
    }
    MKSettingsController *vc = [[MKSettingsController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)switchButtonPressed{
    if (![self canClickEnable]) {
        return;
    }
    if (self.isOverload) {
        [self.view showCentralToast:@"Device is overload"];
        return;
    }
    BOOL isOn = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn);
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    WS(weakSelf);
    [MKMQTTServerInterface setSmartPlugSwitchState:!isOn topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)powerButtonPressed{
    if (![self canClickEnable]) {
        return;
    }
    MKElectricityController *vc = [[MKElectricityController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)timerButtonPressed{
    if (![self canClickEnable]) {
        return;
    }
    BOOL isOn = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn);
    MKConfigDeviceTimeModel *timeModel = [[MKConfigDeviceTimeModel alloc] init];
    timeModel.hour = @"0";
    timeModel.minutes = @"0";
    timeModel.titleMsg = (isOn ? @"Countdown timer(off)" : @"Countdown timer(on)");
    MKConfigDeviceTimePickerView *pickView = [[MKConfigDeviceTimePickerView alloc] init];
    pickView.timeModel = timeModel;
    WS(weakSelf);
    [pickView showTimePickViewBlock:^(MKConfigDeviceTimeModel *timeModel) {
        [weakSelf setDelay:timeModel.hour delayMin:timeModel.minutes];
    }];
}

- (void)energyButtonPressed{
    if (![self canClickEnable]) {
        return;
    }
    MKEnergyController *vc = [[MKEnergyController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - setting
- (void)setDelay:(NSString *)hour delayMin:(NSString *)min{
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface setPlugDelayHour:[hour integerValue] delayMin:[min integerValue] topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)addNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delayTimeNotification:)
                                                 name:MKMQTTServerReceivedDelayTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOverloadStatusChanged:)
                                                 name:MKMQTTServerReceivedOverloadNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceLoadStatusChanged:)
                                                 name:MKMQTTServerLoadStatusChangedNotification
                                               object:nil];
}

- (BOOL)canClickEnable{
    if ([MKMQTTServerManager sharedInstance].managerState != MKMQTTSessionManagerStateConnected) {
        [self.view showCentralToast:@"Network error,please check."];
        return NO;
    }
    if (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOffline) {
        [self.view showCentralToast:@"Device offline,please check."];
        return NO;
    }
    return YES;
}

#pragma mark - config view
- (void)loadSubViews{
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    [self.rightButton setImage:LOADIMAGE(@"configPlugPage_moreIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.delayTimeLabel];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.powerButton];
    [self.bottomView addSubview:self.timerButton];
    [self.bottomView addSubview:self.energyButton];
    [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(switchButtonWidth);
        make.top.mas_equalTo(176.f);
        make.height.mas_equalTo(switchButtonHeight);
    }];
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
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0.f);
        make.bottom.mas_equalTo(-45.f);
        make.height.mas_equalTo(buttonViewHeight);
    }];
    [self.timerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.top.and.bottom.mas_equalTo(0.f);
    }];
    [self.powerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.width.mas_equalTo(buttonViewWidth);
        make.top.and.bottom.mas_equalTo(0.f);
    }];
    [self.energyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-70.f);
        make.width.mas_equalTo(buttonViewWidth);
        make.top.and.bottom.mas_equalTo(0.f);
    }];
}

- (void)configView{
    if (self.isOverload) {
        //是否过载的优先级最高
        [self deviceOverloadUI];
        return;
    }
    
    self.custom_naviBarColor = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x303a4b);
    [self.view setBackgroundColor:((MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? UIColorFromRGB(0xf2f2f2) : UIColorFromRGB(0x303a4b))];
    NSString *switchIcon = ((MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? @"configPlugPage_switchButtonOn" : @"configPlugPage_switchButtonOff");
    self.switchButton.image = LOADIMAGE(switchIcon, @"png");
    self.stateLabel.textColor = ((MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? UIColorFromRGB(0x0188cc) : UIColorFromRGB(0x808080));
    NSString *textMsg = @"Socket is off";
    if (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOffline) {
        textMsg = @"Socket is offline";
    }else if (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn){
        textMsg = @"Socket is on";
    }
    self.stateLabel.text = textMsg;
    
    if (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOffline) {
        [self.delayTimeLabel setHidden:YES];
    }
    
    MKConfigDeviceButtonModel *timerModel = self.dataList[0];
    timerModel.iconName = ((MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? @"configPlugPage_TimerOn" : @"configPlugPage_TimerOff");
    timerModel.isOn = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn);
    self.timerButton.dataModel = timerModel;
    
    MKConfigDeviceButtonModel *powerModel = self.dataList[1];
    powerModel.iconName = ((MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? @"configPlugPage_powerOn" : @"configPlugPage_powerOff");
    powerModel.isOn = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn);
    self.powerButton.dataModel = powerModel;
    
    MKConfigDeviceButtonModel *energyModel = self.dataList[2];
    energyModel.iconName = ((MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn) ? @"configPlugPage_energyOn" : @"configPlugPage_energyOff");
    energyModel.isOn = (MKDeviceModelManager.shared.deviceModel.plugState == MKSmartPlugOn);
    self.energyButton.dataModel = energyModel;
}

- (void)deviceOverloadUI {
    self.custom_naviBarColor = UIColorFromRGB(0x303a4b);
    [self.view setBackgroundColor:UIColorFromRGB(0x303a4b)];
    self.switchButton.image = LOADIMAGE(@"configPlugPage_switchButtonOff", @"png");
    self.stateLabel.textColor = UIColorFromRGB(0x808080);
    self.stateLabel.text = [NSString stringWithFormat:@"Socket is overload,overload value %@W",self.overloadValue];
    [self.delayTimeLabel setHidden:YES];
    
    MKConfigDeviceButtonModel *timerModel = self.dataList[0];
    timerModel.iconName = @"configPlugPage_TimerOff";
    timerModel.isOn = NO;
    self.timerButton.dataModel = timerModel;
    
    MKConfigDeviceButtonModel *powerModel = self.dataList[1];
    powerModel.iconName = @"configPlugPage_powerOff";
    powerModel.isOn = NO;
    self.powerButton.dataModel = powerModel;
    
    MKConfigDeviceButtonModel *energyModel = self.dataList[2];
    energyModel.iconName = @"configPlugPage_energyOff";
    energyModel.isOn = NO;
    self.energyButton.dataModel = energyModel;
}

- (void)loadDataList{
    MKConfigDeviceButtonModel *timerModel = [[MKConfigDeviceButtonModel alloc] init];
    timerModel.msg = @"Timer";
    [self.dataList addObject:timerModel];
    MKConfigDeviceButtonModel *powerModel = [[MKConfigDeviceButtonModel alloc] init];
    powerModel.msg = @"Power";
    [self.dataList addObject:powerModel];
    MKConfigDeviceButtonModel *energyModel = [[MKConfigDeviceButtonModel alloc] init];
    energyModel.msg = @"Energy";
    [self.dataList addObject:energyModel];
}

- (void)readDeviceName {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKDeviceDataBaseManager selectLocalNameWithMacAddress:MKDeviceModelManager.shared.deviceModel.device_id sucBlock:^(NSString *localName) {
        [[MKHudManager share] hide];
        self.defaultTitle = localName;
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        self.defaultTitle = @"";
    }];
}

- (void)initReadTimer{
    self.readTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0,
                                            0,
                                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 10.f * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10.f * NSEC_PER_SEC;
    dispatch_source_set_timer(self.readTimer, start, interval, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.readTimer, ^{
        weakSelf.readTimeout = YES;
        dispatch_cancel(weakSelf.readTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MKHudManager share] hide];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [weakSelf.view showCentralToast:@"Read data timeout!"];
            [weakSelf performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
        });
    });
    dispatch_resume(self.readTimer);
}

- (void)readOverloadStatus {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readOverloadValueWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [self addNotifications];
        [self initReadTimer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
    [MKMQTTServerInterface setDeviceDate:[NSDate date] topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        
    } failedBlock:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - setter & getter
- (UIImageView *)switchButton{
    if (!_switchButton) {
        _switchButton = [[UIImageView alloc] init];
        [_switchButton addTapAction:self selector:@selector(switchButtonPressed)];
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

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = COLOR_CLEAR_MACROS;
    }
    return _bottomView;
}

- (MKConfigDeviceButtonView *)powerButton{
    if (!_powerButton) {
        _powerButton = [[MKConfigDeviceButtonView alloc] init];
        [_powerButton addTapAction:self selector:@selector(powerButtonPressed)];
    }
    return _powerButton;
}

- (MKConfigDeviceButtonView *)timerButton{
    if (!_timerButton) {
        _timerButton = [[MKConfigDeviceButtonView alloc] init];
        [_timerButton addTapAction:self selector:@selector(timerButtonPressed)];
    }
    return _timerButton;
}

- (MKConfigDeviceButtonView *)energyButton{
    if (!_energyButton) {
        _energyButton = [[MKConfigDeviceButtonView alloc] init];
        [_energyButton addTapAction:self selector:@selector(energyButtonPressed)];
    }
    return _energyButton;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray arrayWithCapacity:3];
    }
    return _dataList;
}

@end
