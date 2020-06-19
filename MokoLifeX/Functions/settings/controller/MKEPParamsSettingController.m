//
//  MKEPParamsSettingController.m
//  MokoLifeX
//
//  Created by aa on 2020/6/17.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKEPParamsSettingController.h"

@interface MKEPParamsSettingController ()

@property (nonatomic, strong)UITextField *textField1;

@property (nonatomic, strong)UITextField *textField2;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@end

@implementation MKEPParamsSettingController

- (void)dealloc {
    NSLog(@"MKEPParamsSettingController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self loadDatas];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    if (self.configType == mk_epParamsType_overload) {
        [self setOverloadData];
        return;
    }
    if (self.configType == mk_epParamsType_powerReportPeriod) {
        [self setPowerReportPeriod];
        return;
    }
    if (self.configType == mk_epParamsType_energyReportPeriod) {
        [self setEnergyReportPeriod];
        return;
    }
    if (self.configType == mk_epParamsType_energyInterval) {
        [self setEnergyStorageParameters];
        return;
    }
}

#pragma mark - Notification
- (void)receiveMQTTServerDatas:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    [[MKHudManager share] hide];
    dispatch_cancel(self.readTimer);
    if ([deviceDic[@"function"] integerValue] == 1005) {
        //过载保护
        self.textField1.text = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"overload_value"] integerValue]];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1012) {
        //电量信息上报间隔
        self.textField1.text = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"report_interval"] integerValue]];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1013) {
        //累计电能存储参数
        self.textField1.text = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"time_interval"] integerValue]];
        self.textField2.text = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"power_change"] integerValue]];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1019) {
        //电能上报间隔
        self.textField1.text = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"report_interval"] integerValue]];
        return;
    }
}

#pragma mark - private method

- (void)loadDatas {
    if (self.configType == mk_epParamsType_overload) {
        [self setupUIWithMsg:@"Overload Value (W)"];
        [self readOverloadData];
        return;
    }
    if (self.configType == mk_epParamsType_powerReportPeriod) {
        [self setupUIWithMsg:@"Power report period(s)"];
        [self readPowerReportPeriod];
        return;
    }
    if (self.configType == mk_epParamsType_energyReportPeriod) {
        [self setupUIWithMsg:@"Energy report period(min)"];
        [self readEnergyReportPeriod];
        return;
    }
    if (self.configType == mk_epParamsType_energyInterval) {
        [self loadEnergyIntervalUI];
        [self readEnergyStorageParameters];
        return;
    }
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

#pragma mark - interface

- (void)readOverloadData {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readOverloadValueWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMQTTServerDatas:)
                                                     name:MKMQTTServerReceivedOverloadNotification
                                                   object:nil];
        [self initReadTimer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
}

- (void)setOverloadData {
    if (!ValidStr(self.textField1.text)) {
        [self.view showCentralToast:@"Value cannot be empty"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface setOverloadValue:[self.textField1.text integerValue] topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readPowerReportPeriod {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readPowerReportPeriodWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMQTTServerDatas:)
                                                     name:MKMQTTServerReceivedPowerReportPeriodNotification
                                                   object:nil];
        [self initReadTimer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
}

- (void)setPowerReportPeriod {
    if (!ValidStr(self.textField1.text)) {
        [self.view showCentralToast:@"Value cannot be empty"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface setPowerReportPeriod:[self.textField1.text integerValue] topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readEnergyReportPeriod {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readEnergyReportPeriodWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMQTTServerDatas:)
                                                     name:MKMQTTServerReceivedEnergyReportPeriodNotification
                                                   object:nil];
        [self initReadTimer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
}

- (void)setEnergyReportPeriod {
    if (!ValidStr(self.textField1.text)) {
        [self.view showCentralToast:@"Value cannot be empty"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface setEnergyReportPeriod:[self.textField1.text integerValue] topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readEnergyStorageParameters {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readEnergyStorageParametersWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMQTTServerDatas:)
                                                     name:MKMQTTServerReceivedStorageParametersNotification
                                                   object:nil];
        [self initReadTimer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
}

- (void)setEnergyStorageParameters {
    if (!ValidStr(self.textField1.text) || !ValidStr(self.textField2.text)) {
        [self.view showCentralToast:@"Value cannot be empty"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface setEnergyStorageParameters:[self.textField1.text integerValue] energyValue:[self.textField2.text integerValue] topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UI

- (void)loadEnergyIntervalUI {
    UILabel *msgLabel1 = [self loadMsgLabel:@"Energy accumulated interval(min)"];
    [self.view addSubview:msgLabel1];
    [msgLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 30.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    self.textField1 = [self loadTextField];
    [self.view addSubview:self.textField1];
    [self.textField1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(msgLabel1.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(35.f);
    }];
    UILabel *msgLabel2 = [self loadMsgLabel:@"Energy accumulated interval(min)"];
    [self.view addSubview:msgLabel2];
    [msgLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.textField1.mas_bottom).mas_offset(20.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    self.textField2 = [self loadTextField];
    [self.view addSubview:self.textField2];
    [self.textField2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(msgLabel2.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(35.f);
    }];
    UIButton *confirmButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Confirm"
                                                                       target:self
                                                                       action:@selector(confirmButtonPressed)];
    [self.view addSubview:confirmButton];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(self.textField2.mas_bottom).mas_offset(50.f);
        make.height.mas_equalTo(45.f);
    }];
}

- (void)setupUIWithMsg:(NSString *)msg {
    UILabel *msgLabel = [self loadMsgLabel:msg];
    [self.view addSubview:msgLabel];
    [msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(defaultTopInset + 30.f);
        make.height.mas_equalTo(MKFont(14.f).lineHeight);
    }];
    self.textField1 = [self loadTextField];
    [self.view addSubview:self.textField1];
    [self.textField1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(msgLabel.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(35.f);
    }];
    
    UIButton *confirmButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Confirm"
                                                                       target:self
                                                                       action:@selector(confirmButtonPressed)];
    [self.view addSubview:confirmButton];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(self.textField1.mas_bottom).mas_offset(50.f);
        make.height.mas_equalTo(45.f);
    }];
}

- (UILabel *)loadMsgLabel:(NSString *)msg {
    UILabel *msgLabel = [[UILabel alloc] init];
    msgLabel.textColor = DEFAULT_TEXT_COLOR;
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.font = MKFont(15.f);
    msgLabel.text = msg;
    return msgLabel;
}

- (UITextField *)loadTextField {
    UITextField *textField = [[UITextField alloc] initWithTextFieldType:realNumberOnly];
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.font = MKFont(14.f);
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
    textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
    textField.layer.cornerRadius = 5.f;
    return textField;
}

@end
