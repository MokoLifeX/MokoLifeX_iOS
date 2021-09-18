//
//  MKLFXBOVMDeviceController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBOVMDeviceController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextField.h"
#import "MKCustomUIAdopter.h"
#import "MKProgressView.h"
#import "MKWifiAlertView.h"
#import "MKCAFileSelectController.h"

#import "MKNetworkManager.h"

#import "MKLFXBMQTTManager.h"
#import "MKLFXBSocketInterface.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXSaveDeviceController.h"

#import "MKLFXBOVMDDataModel.h"
#import "MKLFXBOVMDHeaderViewModel.h"

#import "MKLFXBOVMDFileCell.h"
#import "MKLFXBOVMDHeaderView.h"

@interface MKLFXBOVMDeviceController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXBOVMDHeaderViewDelegate,
MKLFXBOVMDFileCellDelegate,
MKCAFileSelectControllerDelegate,
MKLFXBMQTTManagerDeviceOnlineDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKLFXBOVMDHeaderView *tableHeaderView;

@property (nonatomic, strong)MKTextField *subscribedTopicTextField;

@property (nonatomic, strong)MKTextField *publishTopicTextField;

@property (nonatomic, strong)MKLFXBOVMDDataModel *dataModel;

@property (nonatomic, strong)MKWifiAlertView *alertView;

@property (nonatomic, strong)MKProgressView *progressView;

@property (nonatomic, strong)dispatch_source_t connectTimer;

@property (nonatomic, assign)NSInteger timeCount;

@end

@implementation MKLFXBOVMDeviceController

- (void)dealloc {
    NSLog(@"MKLFXBOVMDeviceController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    self.tableHeaderView.dataModel = self.dataModel.headerModel;
    [self loadSectionDatas];
    [self addNotifications];
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataModel.headerModel.connectMode == 0) {
        return 0;
    }
    if (self.dataModel.headerModel.connectMode == 1) {
        return 1;
    }
    if (self.dataModel.headerModel.connectMode == 2) {
        return self.dataList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXBOVMDFileCell *cell = [MKLFXBOVMDFileCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKLFXBOVMDHeaderViewDelegate
/// 用户改变了输入框的值
/// @param text 当前输入框的值
/// @param index 参考如下:
/*
 index的参考值:
 0:host
 1:port
 2:userName
 3:password
 4:keep alive
 5:clientID
 6:deviceID
 */
- (void)lfxb_ovmdHeaderViewTextFieldValueChanged:(NSString *)text index:(NSInteger)index {
    if (index == 0) {
        //host
        self.dataModel.headerModel.host = text;
        return;
    }
    if (index == 1) {
        //port
        self.dataModel.headerModel.port = text;
        return;
    }
    if (index == 2) {
        //userNama
        self.dataModel.headerModel.userName = text;
        return;
    }
    if (index == 3) {
        //password
        self.dataModel.headerModel.password = text;
        return;
    }
    if (index == 4) {
        //keep alive
        self.dataModel.headerModel.keepAlive = text;
        return;
    }
    if (index == 5) {
        //clientID
        self.dataModel.headerModel.clientID = text;
        return;
    }
    if (index == 6) {
        //deviceID
        self.dataModel.headerModel.deviceID = text;
        return;
    }
}

//用户改变了clean session值
- (void)lfxb_ovmdHeaderViewCleanSessionChanged:(BOOL)isOn {
    self.dataModel.headerModel.cleanSession = isOn;
    
    [self.subscribedTopicTextField resignFirstResponder];
    [self.publishTopicTextField resignFirstResponder];
}

//用户改变了qos值
- (void)lfxb_ovmdHeaderViewQosChanged:(NSInteger)qos {
    self.dataModel.headerModel.qos = qos;
    
    [self.subscribedTopicTextField resignFirstResponder];
    [self.publishTopicTextField resignFirstResponder];
}

/// 用户选择了connectMode
/// @param connectMode 0(TCP)/1(One-way SSL)/2(Two-way SSL)
- (void)lfxb_ovmdHeaderViewConnectModeChanged:(NSInteger)connectMode {
    self.dataModel.headerModel.connectMode = connectMode;
    [self.tableView reloadData];
    
    [self.subscribedTopicTextField resignFirstResponder];
    [self.publishTopicTextField resignFirstResponder];
}

#pragma mark - MKLFXBOVMDFileCellDelegate

/// 用户选择证书
/// @param index 0:CA File  1:Client Key  2:Client Certificate File
- (void)lfxb_certFileButtonPressed:(NSInteger)index {
    MKCAFileSelectController *vc = [[MKCAFileSelectController alloc] init];
    vc.pageType = index;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MKCAFileSelectControllerDelegate
- (void)mk_certSelectedMethod:(mk_certListPageType)certType certName:(NSString *)certName {
    MKLFXBOVMDFileCellModel *cellModel = self.dataList[certType];
    cellModel.certName = certName;
    [self.tableView mk_reloadRow:certType inSection:0 withRowAnimation:UITableViewRowAnimationNone];
    if (certType == mk_caCertSelPage) {
        self.dataModel.caFileName = certName;
        return;
    }
    if (certType == mk_clientKeySelPage) {
        self.dataModel.clientKeyName = certName;
        return;
    }
    if (certType == mk_clientCertSelPage) {
        self.dataModel.clientCertName = certName;
        return;
    }
}

#pragma mark - MKLFXBMQTTManagerDeviceOnlineDelegate
- (void)lfxb_deviceOnline:(NSString *)deviceID {
    if (!ValidStr(deviceID) || ![self.dataModel.headerModel.deviceID isEqualToString:deviceID]) {
        return;
    }
    //接收到设备的网络状态上报，认为设备入网成功
    [MKLFXBMQTTManager shared].delegate = nil;
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    self.timeCount = 0;
    [self.progressView setProgress:1.f animated:YES];
    [self performSelector:@selector(connectSuccess) withObject:nil afterDelay:.5f];
}

#pragma mark - note
- (void)networkChanged {
    if (![MKNetworkManager currentWifiIsCorrect]) {
        //返回上一级页面
        [self.alertView dismiss];
        [self.view showCentralToast:@"Please confirm whether the current wifi connection is the target device!"];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
        return;
    }
}

#pragma mark - event method
- (void)nextButtonPressed {
    if (![MKNetworkManager currentWifiIsCorrect]) {
        [self.view showCentralToast:@"Please confirm whether the current wifi connection is the target device!"];
        return;
    }
    NSString *msg = [self.dataModel checkParams];
    if (ValidStr(msg)) {
        [self.view showCentralToast:msg];
        return;
    }
    @weakify(self);
    [self.alertView showWithConfirmBlock:^(NSString * _Nonnull ssid, NSString * _Nonnull password) {
        @strongify(self);
        [self configMQTTServerParams:ssid password:password];
    }];
}

#pragma mark - private method
- (void)configMQTTServerParams:(NSString *)ssid password:(NSString *)password {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [self.dataModel configDeviceWithWifiSSID:ssid wifiPassword:password sucBlock:^{
        [[MKHudManager share] hide];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self configServerParamsComplete];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configServerParamsComplete {
    NSString *topic = @"";
    if (ValidStr([MKLFXBMQTTManager shared].subscribeTopic)) {
        //查看是否设置了服务器的订阅topic
        topic = [MKLFXBMQTTManager shared].subscribeTopic;
    }else {
        topic = self.dataModel.publishTopic;
    }
    [self.progressView show];
    [[MKLFXBMQTTManager shared] subscriptions:@[topic]];
    [MKLFXBMQTTManager shared].delegate = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.timeCount = 0;
    dispatch_source_set_timer(self.connectTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    @weakify(self);
    dispatch_source_set_event_handler(self.connectTimer, ^{
        @strongify(self);
        if (self.timeCount >= 90) {
            //接受数据超时
            dispatch_cancel(self.connectTimer);
            self.timeCount = 0;
            [MKLFXBMQTTManager shared].delegate = nil;
            moko_dispatch_main_safe(^{
                [self.progressView dismiss];
                [self.view showCentralToast:@"Connect Failed!"];
                [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
            });
            return ;
        }
        self.timeCount ++;
        moko_dispatch_main_safe(^{
            [self.progressView setProgress:(self.timeCount / 90.f) animated:NO];
        });
    });
    dispatch_resume(self.connectTimer);
}

- (void)connectSuccess {
    if (self.alertView) {
        [self.alertView dismiss];
    }
    if (self.progressView) {
        [self.progressView dismiss];
    }
    [MKLFXBMQTTManager singleDealloc];
    [MKLFXBSocketInterface sharedDealloc];
    MKLFXDeviceModel *deviceModel = [[MKLFXDeviceModel alloc] init];
    deviceModel.deviceID = self.dataModel.headerModel.deviceID;
    deviceModel.clientID = self.dataModel.headerModel.clientID;
    deviceModel.subscribedTopic = self.dataModel.subscribeTopic;
    deviceModel.publishedTopic = self.dataModel.publishTopic;
    deviceModel.macAddress = self.deviceInfo[@"device_id"];
    deviceModel.deviceName = self.deviceInfo[@"device_name"];
    deviceModel.deviceType = [NSString stringWithFormat:@"%ld",(long)[self.deviceInfo[@"device_type"] integerValue]];
    deviceModel.state = MKLFXDeviceModelStateOff;
    
    MKLFXSaveDeviceController *vc = [[MKLFXSaveDeviceController alloc] init];
    vc.deviceModel = deviceModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged)
                                                 name:MKNetworkStatusChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(networkChanged)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKLFXBOVMDFileCellModel *cellModel1 = [[MKLFXBOVMDFileCellModel alloc] init];
    cellModel1.msg = @"CA File:";
    cellModel1.index = 0;
    [self.dataList addObject:cellModel1];
    
    MKLFXBOVMDFileCellModel *cellModel2 = [[MKLFXBOVMDFileCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Client Key:";
    [self.dataList addObject:cellModel2];
    
    MKLFXBOVMDFileCellModel *cellModel3 = [[MKLFXBOVMDFileCellModel alloc] init];
    cellModel3.index = 2;
    cellModel3.msg = @"Client Certificate File:";
    [self.dataList addObject:cellModel3];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"MQTT settings for Device";
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableHeaderView = self.tableHeaderView;
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKLFXBOVMDHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[MKLFXBOVMDHeaderView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 400.f)];
        _tableHeaderView.delegate = self;
    }
    return _tableHeaderView;
}

- (MKTextField *)subscribedTopicTextField {
    if (!_subscribedTopicTextField) {
        _subscribedTopicTextField = [self loadTopicTextField];
        @weakify(self);
        _subscribedTopicTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            self.dataModel.subscribeTopic = text;
        };
    }
    return _subscribedTopicTextField;
}

- (MKTextField *)publishTopicTextField {
    if (!_publishTopicTextField) {
        _publishTopicTextField = [self loadTopicTextField];
        @weakify(self);
        _publishTopicTextField.textChangedBlock = ^(NSString * _Nonnull text) {
            @strongify(self);
            self.dataModel.publishTopic = text;
        };
    }
    return _publishTopicTextField;
}

- (MKLFXBOVMDDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXBOVMDDataModel alloc] init];
    }
    return _dataModel;
}

- (MKWifiAlertView *)alertView {
    if (!_alertView) {
        _alertView = [[MKWifiAlertView alloc] init];
    }
    return _alertView;
}

- (MKProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[MKProgressView alloc] initWithTitle:@"Connecting now!"
                                                      message:@"Make sure your device is as close to your router as possible"];
    }
    return _progressView;
}

- (UIView *)tableFooterView {
    CGFloat footerViewHeight = 200.f;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, footerViewHeight)];
    tableFooterView.backgroundColor = RGBCOLOR(242, 242, 242);
    
    CGFloat labelWidth = 120.f;
    CGFloat labelHeight = 35.f;
    
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 5.f, labelWidth, labelHeight)];
    subLabel.textColor = DEFAULT_TEXT_COLOR;
    subLabel.textAlignment = NSTextAlignmentLeft;
    subLabel.font = MKFont(15.f);
    subLabel.text = @"Subscribed Topic";
    [tableFooterView addSubview:subLabel];
    
    [tableFooterView addSubview:self.subscribedTopicTextField];
    self.subscribedTopicTextField.frame = CGRectMake(15.f + labelWidth + 5.f, 5.f, kViewWidth - 2 * 15.f - labelWidth - 5.f, labelHeight);
    
    CGFloat pubOffset_Y = 5.f + labelHeight + 10.f;
    UILabel *pubLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, pubOffset_Y, labelWidth, labelHeight)];
    pubLabel.textColor = DEFAULT_TEXT_COLOR;
    pubLabel.textAlignment = NSTextAlignmentLeft;
    pubLabel.font = MKFont(15.f);
    pubLabel.text = @"Published Topic";
    [tableFooterView addSubview:pubLabel];
    
    [tableFooterView addSubview:self.publishTopicTextField];
    self.publishTopicTextField.frame = CGRectMake(15.f + labelWidth + 5.f, pubOffset_Y, kViewWidth - 2 * 15.f - labelWidth - 5.f, labelHeight);
    
    UIButton *nextButton = [MKCustomUIAdopter customButtonWithTitle:@"Next"
                                                             target:self
                                                             action:@selector(nextButtonPressed)];
    [tableFooterView addSubview:nextButton];
    nextButton.frame = CGRectMake(30.f, footerViewHeight - 30.f - 40.f, kViewWidth - 2 * 30.f, 40.f);
    
    return tableFooterView;
}

- (MKTextField *)loadTopicTextField {
    MKTextField *textField = [[MKTextField alloc] init];
    textField.textType = mk_normal;
    textField.borderStyle = UITextBorderStyleNone;
    textField.maxLength = 128;
    textField.placeholder = @"1-128 Characters";
    textField.font = MKFont(13.f);
    textField.textColor = DEFAULT_TEXT_COLOR;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.layer.masksToBounds = YES;
    textField.layer.borderColor = CUTTING_LINE_COLOR.CGColor;
    textField.layer.borderWidth = CUTTING_LINE_HEIGHT;
    textField.layer.cornerRadius = 6.f;
    return textField;
}

@end
