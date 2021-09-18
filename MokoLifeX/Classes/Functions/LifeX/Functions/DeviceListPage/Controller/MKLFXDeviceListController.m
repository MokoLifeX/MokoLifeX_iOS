//
//  MKLFXDeviceListController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXDeviceListController.h"

#import <CoreLocation/CoreLocation.h>

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"
#import "NSObject+MKModel.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"
#import "MKAlertController.h"
#import "MKAboutController.h"

#import "MKLFXServerForAppController.h"

#import "MKLFXDeviceModel.h"

#import "MKNetworkManager.h"

#import "MKLFXMQTTManager.h"
#import "MKLFXMQTTInterface.h"

#import "MKLFXDeviceListDatabaseManager.h"

#import "MKLFXAddDeviceView.h"
#import "MKLFXDeviceListCell.h"
#import "MKLFXEasyShowView.h"

#import "MKLFXAddDeviceController.h"

#import "MKLFXASwitchStateController.h"
#import "MKLFXBSwitchStateController.h"
#import "MKLFXCSwitchStateController.h"

static NSTimeInterval const kRefreshInterval = 0.5f;

@interface MKLFXDeviceListController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXDeviceListCellDelegate>

/// 没有添加设备的时候显示
@property (nonatomic, strong)MKLFXAddDeviceView *addView;

/// 本地有设备的时候显示
@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)UIView *footerView;

@property (nonatomic, strong)MKLFXEasyShowView *loadingView;

@property (nonatomic, strong)NSMutableArray *dataList;

/// 定时刷新
@property (nonatomic, assign)CFRunLoopObserverRef observerRef;
//不能立即刷新列表，降低刷新频率
@property (nonatomic, assign)BOOL isNeedRefresh;

@end

@implementation MKLFXDeviceListController

- (void)dealloc {
    NSLog(@"MKLFXDeviceListController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //移除runloop的监听
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readDataFromDatabase];
    [self runloopObserver];
    [self addNotifications];
}

#pragma mark - super method
- (void)leftButtonMethod {
    MKLFXServerForAppController *vc = [[MKLFXServerForAppController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)rightButtonMethod {
    MKAboutController *vc = [[MKAboutController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXDeviceModel *deviceModel = self.dataList[indexPath.row];
    if ([deviceModel.deviceType isEqualToString:@"4"] || [deviceModel.deviceType isEqualToString:@"5"]) {
        //当前设备是MK117、MK117D
        MKLFXCSwitchStateController *vc = [[MKLFXCSwitchStateController alloc] init];
        vc.deviceModel = deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (deviceModel.state == MKLFXDeviceModelStateOffline) {
        [self.view showCentralToast:@"Device is off-line!"];
        return;
    }
    if ([deviceModel.deviceType isEqualToString:@"0"] || [deviceModel.deviceType isEqualToString:@"1"]) {
        //当前设备是MK112、MK114
        MKLFXASwitchStateController *vc = [[MKLFXASwitchStateController alloc] init];
        vc.deviceModel = deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([deviceModel.deviceType isEqualToString:@"2"] || [deviceModel.deviceType isEqualToString:@"3"]) {
        //当前设备是MK115、MK116
        MKLFXBSwitchStateController *vc = [[MKLFXBSwitchStateController alloc] init];
        vc.deviceModel = deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXDeviceListCell *cell = [MKLFXDeviceListCell initCellWithTableView:tableView];
    cell.indexPath = indexPath;
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKLFXDeviceListCellDelegate
- (void)lfx_deviceStateChanged:(MKLFXDeviceModel *)deviceModel {
    if (deviceModel.state == MKLFXDeviceModelStateOffline) {
        [self.view showCentralToast:@"Device is offline, please check it!"];
        return;
    }
    if (deviceModel.overState == MKLFXDeviceOverState_overLoad) {
        //过载
        [self.view showCentralToast:@"Device is overload, please check it!"];
        return;
    }
    if (deviceModel.overState == MKLFXDeviceOverState_overCurrent) {
        //过流
        [self.view showCentralToast:@"Device is overcurrent, please check it!"];
        return;
    }
    if (deviceModel.overState == MKLFXDeviceOverState_overVoltage) {
        //过压
        [self.view showCentralToast:@"Device is overvoltage, please check it!"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    BOOL isOn = (deviceModel.state == MKLFXDeviceModelStateOn);
    [MKLFXMQTTInterface lfx_configDeviceSwitchState:!isOn
                                           deviceID:deviceModel.deviceID
                                              topic:[deviceModel currentSubscribedTopic]
                                           sucBlock:^{
        [[MKHudManager share] hide];
    }
                                        failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)lfx_cellDeleteButtonPressed:(NSInteger)index {
    if (index >= self.dataList.count) {
        return;
    }
    
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Remove Device"
                                                                       message:@"Please confirm again whether to remove the device."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self removeDeviceFromLocal:index];
    }];
    [alertView addAction:moreAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - MKLFXDeviceModelDelegate
/// 当前设备离线
/// @param deviceID 当前设备的deviceID
- (void)lfx_deviceOfflineWithDeviceID:(NSString *)deviceID {
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXDeviceModel *deviceModel = self.dataList[i];
        if ([deviceModel.deviceID isEqualToString:deviceID]) {
            deviceModel.state = MKLFXDeviceModelStateOffline;
            break;
        }
    }
    [self needRefreshList];
}

#pragma mark - note
- (void)receiveNewDevice:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user)) {
        return;
    }
    MKLFXDeviceModel *deviceModel = user[@"deviceModel"];
    deviceModel.delegate = self;
    [deviceModel startStateMonitoringTimer];
    
    NSInteger index = 0;
    BOOL contain = NO;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXDeviceModel *model = self.dataList[i];
        if ([model.macAddress isEqualToString:deviceModel.macAddress]) {
            index = i;
            contain = YES;
            break;
        }
    }
    if (contain) {
        //当前设备列表存在deviceID相同的设备，替换，本地数据库已经替换过了
        [self.dataList replaceObjectAtIndex:index withObject:deviceModel];
    }else {
        //不存在，则添加到设备列表
        [self.dataList addObject:deviceModel];
    }
    
    [self loadMainViews];
    [[MKLFXMQTTManager shared] subscriptions:@[[deviceModel currentPublishedTopic]]];
}

/// 设备在线通知
/// @param note 通知
/*
    注意，因为这个在线状态没有开关状态，所以业务要求如下，当前设备是在线状态，则只清零计数不改变状态，如果是离线状态则显示开关关闭状态
 */
- (void)receiveDeviceOnlineState:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user) || !ValidStr(user[@"deviceID"]) || self.dataList.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXDeviceModel *deviceModel = self.dataList[i];
        if ([deviceModel.deviceID isEqualToString:user[@"deviceID"]]) {
            [deviceModel resetTimerCounter];
            if (deviceModel.state == MKLFXDeviceModelStateOffline) {
                deviceModel.state = MKLFXDeviceModelStateOff;
            }
            break;
        }
    }
    [self needRefreshList];
}

- (void)receiveSwitchState:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user) || !ValidStr(user[@"id"]) || self.dataList.count == 0) {
        return;
    }
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXDeviceModel *deviceModel = self.dataList[i];
        if ([deviceModel.deviceID isEqualToString:user[@"id"]]) {
            [deviceModel resetTimerCounter];
            MKLFXDeviceModelState state = ([user[@"data"][@"switch_state"] isEqualToString:@"on"] ? MKLFXDeviceModelStateOn : MKLFXDeviceModelStateOff);
            deviceModel.state = state;
            MKLFXDeviceOverState overState = MKLFXDeviceOverState_normal;
            if (ValidNum(user[@"data"][@"overload_state"]) && [user[@"data"][@"overload_state"] integerValue] == 1) {
                overState = MKLFXDeviceOverState_overLoad;
            }else if (ValidNum(user[@"data"][@"overcurrent_state"]) && [user[@"data"][@"overcurrent_state"] integerValue] == 1) {
                overState = MKLFXDeviceOverState_overCurrent;
            }else if (ValidNum(user[@"data"][@"overvoltage_state"]) && [user[@"data"][@"overvoltage_state"] integerValue] == 1) {
                overState = MKLFXDeviceOverState_overVoltage;
            }
            deviceModel.overState = overState;
            break;
        }
    }
    [self needRefreshList];
}

- (void)receiveDeviceNameChanged:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user) || !ValidStr(user[@"macAddress"]) || self.dataList.count == 0) {
        return;
    }
    NSInteger index = 0;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXDeviceModel *deviceModel = self.dataList[i];
        if ([deviceModel.macAddress isEqualToString:user[@"macAddress"]]) {
            deviceModel.deviceName = user[@"deviceName"];
            index = i;
            break;
        }
    }
    [self.tableView mk_reloadRow:index inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)receiveDeleteDevice:(NSNotification *)note {
    NSDictionary *user = note.userInfo;
    if (!ValidDict(user) || !ValidStr(user[@"macAddress"]) || self.dataList.count == 0) {
        return;
    }
    MKLFXDeviceModel *deviceModel = nil;
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXDeviceModel *model = self.dataList[i];
        if ([model.macAddress isEqualToString:user[@"macAddress"]]) {
            deviceModel = model;
            break;
        }
    }
    
    if (!deviceModel) {
        return;
    }
    [[MKLFXMQTTManager shared] unsubscriptions:@[[deviceModel currentPublishedTopic]]];
    [self.dataList removeObject:deviceModel];
    
    [self loadMainViews];
}

/// 当前MQTT服务器连接状态发生改变
- (void)serverManagerStateChanged {
    if ([MKLFXMQTTManager shared].state == MKLFXMQTTSessionManagerStateConnecting) {
        [self.loadingView showText:@"Connecting..." superView:self.titleLabel animated:YES];
        return;
    }
    if ([MKLFXMQTTManager shared].state == MKLFXMQTTSessionManagerStateConnected) {
        [self.loadingView hidden];
        self.defaultTitle = @"MokolifeX";
        return;
    }
    if ([MKLFXMQTTManager shared].state == MKLFXMQTTSessionManagerStateError) {
        [self.loadingView hidden];
        self.defaultTitle = @"Connect Failed";
        return;
    }
}

- (void)networkStatusChanged {
    if (![[MKNetworkManager sharedInstance] currentNetworkAvailable]) {
        self.defaultTitle = @"Network Unreachable";
        return;
    }
}

#pragma mark - event method
- (void)addButtonPressed {
    if ([kSystemVersionString floatValue] >= 13 && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
            //未授权位置信息
            [self showAuthAlert];
            return;
        }
    if (![MKLFXMQTTManager shared].MQTTParams) {
        //如果MQTT服务器参数不存在，则去引导用户添加服务器参数，让app连接MQTT服务器
        [self leftButtonMethod];
        return;
    }
    //MQTT服务器参数存在，则添加设备
    MKLFXAddDeviceController *vc = [[MKLFXAddDeviceController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - private method
- (void)showAuthAlert {
    NSString *msg = @"Please go to Settings-Privacy-Location Services to turn on location services permission.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Note"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)removeDeviceFromLocal:(NSInteger)index {
    MKLFXDeviceModel *deviceModel = self.dataList[index];
    [[MKHudManager share] showHUDWithTitle:@"Delete..." inView:self.view isPenetration:NO];
    [MKLFXDeviceListDatabaseManager deleteDeviceWithMacAddress:deviceModel.macAddress sucBlock:^{
        [[MKHudManager share] hide];
        [self.dataList removeObject:deviceModel];
        [[MKLFXMQTTManager shared] unsubscriptions:@[[deviceModel currentPublishedTopic]]];
        [self loadMainViews];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)loadMainViews {
    if (self.tableView.superview) {
        [self.tableView removeFromSuperview];
    }
    if (self.addView.superview) {
        [self.addView removeFromSuperview];
    }
    if (!ValidArray(self.dataList)) {
        //没有设备的情况下，隐藏设备列表，显示添加设备页面
        [self.view addSubview:self.addView];
        [self.addView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(defaultTopInset);
            make.bottom.mas_equalTo(self.footerView.mas_top);
        }];
        return;
    }
    //有设备了，显示设备列表
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(self.footerView.mas_top);
    }];
    [self.tableView reloadData];
}

- (void)readDataFromDatabase {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXDeviceListDatabaseManager readLocalDeviceWithSucBlock:^(NSArray<MKLFXDeviceModel *> * _Nonnull deviceList) {
        [[MKHudManager share] hide];
        [self loadTopics:deviceList];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)loadTopics:(NSArray<MKLFXDeviceModel *>*)deviceList {
    NSMutableArray *topicList = [NSMutableArray array];
    for (NSInteger i = 0; i < deviceList.count; i ++) {
        MKLFXDeviceModel *deviceModel = deviceList[i];
        deviceModel.delegate = self;
        [deviceModel startStateMonitoringTimer];
        [self.dataList addObject:deviceModel];
        [topicList addObject:[deviceModel currentPublishedTopic]];
    }
    [self loadMainViews];
    [[MKLFXMQTTManager shared] subscriptions:topicList];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNewDevice:)
                                                 name:@"mk_lfx_addNewDeviceSuccessNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOnlineState:)
                                                 name:MKLFXReceiveDeviceOnlineStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveSwitchState:)
                                                 name:MKLFXReceivedSwitchStateNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceNameChanged:)
                                                 name:@"mk_lfx_deviceNameChangedNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeleteDevice:)
                                                 name:@"mk_lfx_deleteDeviceNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(serverManagerStateChanged)
                                                 name:MKLFXMQTTManagerStateChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged)
                                                 name:MKNetworkStatusChangedNotification
                                               object:nil];
}

#pragma mark - 定时刷新

- (void)needRefreshList {
    //标记需要刷新
    self.isNeedRefresh = YES;
    //唤醒runloop
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

- (void)runloopObserver {
    @weakify(self);
    __block NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    self.observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        @strongify(self);
        if (activity == kCFRunLoopBeforeWaiting) {
            //runloop空闲的时候刷新需要处理的列表,但是需要控制刷新频率
            NSTimeInterval currentInterval = [[NSDate date] timeIntervalSince1970];
            if (currentInterval - timeInterval < kRefreshInterval) {
                return;
            }
            timeInterval = currentInterval;
            if (self.isNeedRefresh) {
                [self.tableView reloadData];
                self.isNeedRefresh = NO;
            }
        }
    });
    //添加监听，模式为kCFRunLoopCommonModes
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), self.observerRef, kCFRunLoopCommonModes);
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Moko LifeX";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXDeviceListController", @"lfx_aboutMenuIcon.png") forState:UIControlStateNormal];
    [self.leftButton setImage:LOADICON(@"MokoLifeX", @"MKLFXDeviceListController", @"lfx_menuIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.footerView];
    [self.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
        make.height.mas_equalTo(100.f);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (MKLFXAddDeviceView *)addView {
    if (!_addView) {
        _addView = [[MKLFXAddDeviceView alloc] init];
    }
    return _addView;
}

- (MKLFXEasyShowView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[MKLFXEasyShowView alloc] init];
    }
    return _loadingView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = COLOR_WHITE_MACROS;
        UIButton *addButton = [MKCustomUIAdopter customButtonWithTitle:@"Add Devices"
                                                                target:self
                                                                action:@selector(addButtonPressed)];
        [_footerView addSubview:addButton];
        [addButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(60.f);
            make.right.mas_equalTo(-60.f);
            make.centerY.mas_equalTo(_footerView.mas_centerY);
            make.height.mas_equalTo(40.f);
        }];
    }
    return _footerView;
}

@end
