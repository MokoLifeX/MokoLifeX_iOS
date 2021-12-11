//
//  MKLFXBConfigDataController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBConfigDataController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXBMQTTInterface.h"
#import "MKLFXBMQTTManager.h"

#import "MKLFXBConfigDataCell.h"

@interface MKLFXBConfigDataController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXBConfigDataCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKLFXBConfigDataController

- (void)dealloc {
    NSLog(@"MKLFXBConfigDataController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [self addNotification];
    [self readDatasFromServer];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXBConfigDataCell *cell = [MKLFXBConfigDataCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKLFXBConfigDataCellDelegate
- (void)lfxb_configDataValueChanged:(NSString *)text index:(NSInteger)index {
    MKLFXBConfigDataCellModel * cellModel = self.dataList[index];
    cellModel.value = text;
}

#pragma mark - note
- (void)receiveOverloadValue:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1005) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    MKLFXBConfigDataCellModel *cellModel = self.dataList[0];
    cellModel.value = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"overload_value"]];
    [self.tableView reloadData];
}

- (void)receivePowerReportPeriod:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1012) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    MKLFXBConfigDataCellModel *cellModel = self.dataList[0];
    cellModel.value = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"report_interval"]];
    [self.tableView reloadData];
}

- (void)receiveStorageParameters:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1013) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    
    MKLFXBConfigDataCellModel *cellModel1 = self.dataList[0];
    cellModel1.value = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"time_interval"]];
    [self.tableView reloadData];
    
    MKLFXBConfigDataCellModel *cellModel2 = self.dataList[1];
    cellModel2.value = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"power_change"]];
    [self.tableView reloadData];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    [self configDataParams];
}

#pragma mark - interface
- (void)readDatasFromServer {
    if (self.pageType == mk_lfxb_configDataPageType_overloadValue) {
        [self readOverloadValue];
        return;
    }
    if (self.pageType == mk_lfxb_configDataPageType_powerReport) {
        [self readPowerReport];
        return;
    }
    if (self.pageType == mk_lfxb_configDataPageType_energyStorage) {
        [self readEnergyStorage];
        return;
    }
}

- (void)configDataParams {
    for (MKLFXBConfigDataCellModel *cellModel in self.dataList) {
        if (!ValidStr(cellModel.value)) {
            [self.view showCentralToast:@"Params cannot be empty!"];
            return;
        }
    }
    if (self.pageType == mk_lfxb_configDataPageType_overloadValue) {
        [self configOverloadValue];
        return;
    }
    if (self.pageType == mk_lfxb_configDataPageType_powerReport) {
        [self configPowerReport];
        return;
    }
    if (self.pageType == mk_lfxb_configDataPageType_energyStorage) {
        [self configEnergyStorage];
        return;
    }
}

- (void)readOverloadValue {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_readOverloadValueWithDeviceID:self.deviceModel.deviceID
                                                      topic:[self.deviceModel currentSubscribedTopic]
                                                   sucBlock:^{
        [self startReadTimer];
    }
                                                failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configOverloadValue {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    
    MKLFXBConfigDataCellModel *cellModel = self.dataList[0];
    
    [MKLFXBMQTTInterface lfxb_setOverloadValue:[cellModel.value integerValue]
                                      deviceID:self.deviceModel.deviceID
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

- (void)readPowerReport {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_readPowerReportPeriodWithDeviceID:self.deviceModel.deviceID
                                                          topic:[self.deviceModel currentSubscribedTopic]
                                                       sucBlock:^{
        [self startReadTimer];
    }
                                                    failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configPowerReport {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    
    MKLFXBConfigDataCellModel *cellModel = self.dataList[0];
    
    [MKLFXBMQTTInterface lfxb_setPowerReportPeriod:[cellModel.value integerValue]
                                          deviceID:self.deviceModel.deviceID
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

- (void)readEnergyStorage {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_readEnergyStorageParametersWithDeviceID:self.deviceModel.deviceID
                                                                topic:[self.deviceModel currentSubscribedTopic]
                                                             sucBlock:^{
        [self startReadTimer];
    }
                                                          failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configEnergyStorage {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    
    MKLFXBConfigDataCellModel *cellModel1 = self.dataList[0];
    MKLFXBConfigDataCellModel *cellModel2 = self.dataList[1];
    [MKLFXBMQTTInterface lfxb_setEnergyStorageParameters:[cellModel1.value integerValue]
                                             energyValue:[cellModel2.value integerValue]
                                                deviceID:self.deviceModel.deviceID
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

#pragma mark - private method
- (void)addNotification {
    if (self.pageType == mk_lfxb_configDataPageType_overloadValue) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOverloadValue:)
                                                     name:MKLFXBReceiveOverloadNotification
                                                   object:nil];
        return;
    }
    if (self.pageType == mk_lfxb_configDataPageType_powerReport) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivePowerReportPeriod:)
                                                     name:MKLFXBReceivePowerReportPeriodNotification
                                                   object:nil];
        return;
    }
    if (self.pageType == mk_lfxb_configDataPageType_energyStorage) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveStorageParameters:)
                                                     name:MKLFXBReceiveStorageParametersNotification
                                                   object:nil];
        return;
    }
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    if (self.pageType == mk_lfxb_configDataPageType_overloadValue) {
        [self loadOverloadDatas];
    }else if (self.pageType == mk_lfxb_configDataPageType_powerReport) {
        [self loadPowerReportDatas];
    }else if (self.pageType == mk_lfxb_configDataPageType_energyStorage) {
        [self loadEnergyStorageDatas];
    }
    [self.tableView reloadData];
}

- (void)loadOverloadDatas {
    MKLFXBConfigDataCellModel *cellModel = [[MKLFXBConfigDataCellModel alloc] init];
    cellModel.msg = @"Overload Value(W)";
    cellModel.index = 0;
    cellModel.placeholder = @"";
    cellModel.maxLen = 4;
    [self.dataList addObject:cellModel];
}

- (void)loadPowerReportDatas {
    MKLFXBConfigDataCellModel *cellModel = [[MKLFXBConfigDataCellModel alloc] init];
    cellModel.msg = @"Power report period(s)";
    cellModel.index = 0;
    cellModel.placeholder = @"1-600s";
    cellModel.maxLen = 3;
    [self.dataList addObject:cellModel];
}

- (void)loadEnergyStorageDatas {
    MKLFXBConfigDataCellModel *cellModel1 = [[MKLFXBConfigDataCellModel alloc] init];
    cellModel1.msg = @"Energy report interval(min)";
    cellModel1.index = 0;
    cellModel1.placeholder = @"1-60Mins";
    cellModel1.maxLen = 2;
    [self.dataList addObject:cellModel1];
    
    MKLFXBConfigDataCellModel *cellModel2 = [[MKLFXBConfigDataCellModel alloc] init];
    cellModel2.msg = @"Power change notification(%)";
    cellModel2.index = 1;
    cellModel2.placeholder = @"1-100%";
    cellModel2.maxLen = 3;
    [self.dataList addObject:cellModel2];
}

#pragma mark - UI
- (void)loadSubViews {
    if (self.pageType == mk_lfxb_configDataPageType_overloadValue) {
        self.defaultTitle = @"Overload Value";
    }else if (self.pageType == mk_lfxb_configDataPageType_powerReport) {
        self.defaultTitle = @"Power Report Period";
    }else if (self.pageType == mk_lfxb_configDataPageType_energyStorage) {
        self.defaultTitle = @"Energy Report Parameters";
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIView *)tableFooterView {
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 120.f)];
    
    UIButton *confirmButton = [MKCustomUIAdopter customButtonWithTitle:@"Confirm"
                                                                target:self
                                                                action:@selector(confirmButtonPressed)];
    confirmButton.frame = CGRectMake(30.f, 70.f, kViewWidth - 2 * 30.f, 40.f);
    [tableFooterView addSubview:confirmButton];
    
    return tableFooterView;
}

@end
