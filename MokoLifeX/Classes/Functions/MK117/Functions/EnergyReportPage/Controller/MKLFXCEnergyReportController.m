//
//  MKLFXCEnergyReportController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCEnergyReportController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTManager.h"

#import "MKLFXCEnergyReportCell.h"

#import "MKLFXCEnergyReportModel.h"

@interface MKLFXCEnergyReportController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXCEnergyReportCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKLFXCEnergyReportModel *dataModel;

@end

@implementation MKLFXCEnergyReportController

- (void)dealloc {
    NSLog(@"MKLFXCEnergyReportController销毁");
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveEnergyParams:)
                                                 name:MKLFXCReceiveEnergyParamsNotification
                                               object:nil];
    [self readDataFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    if (!ValidStr(self.dataModel.interval) || [self.dataModel.interval integerValue] < 1 || [self.dataModel.interval integerValue] > 60 || !ValidStr(self.dataModel.powerChange) || [self.dataModel.powerChange integerValue] < 1 || [self.dataModel.powerChange integerValue] > 100) {
        [self.view showCentralToast:@"Params error"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configEnergyParams:[self.dataModel.interval integerValue]
                                     powerChange:[self.dataModel.powerChange integerValue]
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXCEnergyReportCell *cell = [MKLFXCEnergyReportCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKLFXCEnergyReportCellDelegate
- (void)lfxc_textFieldValueChanged:(NSString *)text index:(NSInteger)index {
    MKLFXCEnergyReportCellModel *cellModel = self.dataList[index];
    cellModel.textValue = text;
    if (index == 0) {
        //Energy report interval
        self.dataModel.interval = text;
        return;
    }
    if (index == 1) {
        //Power change notification
        self.dataModel.powerChange = text;
        return;
    }
}

#pragma mark - note
- (void)receiveEnergyParams:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1013) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    
    self.dataModel.interval = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"time_interval"]];
    MKLFXCEnergyReportCellModel *cellModel1 = self.dataList[0];
    cellModel1.textValue = self.dataModel.interval;
    
    self.dataModel.powerChange = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"power_change"]];
    MKLFXCEnergyReportCellModel *cellModel2 = self.dataList[1];
    cellModel2.textValue = self.dataModel.powerChange;
    
    [self.tableView reloadData];
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_readEnergyParamsWithDeviceID:self.deviceModel.deviceID
                                                     topic:[self.deviceModel currentSubscribedTopic]
                                                  sucBlock:^{
        [self startReadTimer];
    }
                                               failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKLFXCEnergyReportCellModel *cellModel1 = [[MKLFXCEnergyReportCellModel alloc] init];
    cellModel1.msg = @"Energy report interval";
    cellModel1.index = 0;
    cellModel1.maxLen = 2;
    cellModel1.noteMsg = @"Range: 1-60, unit: min";
    [self.dataList addObject:cellModel1];
    
    MKLFXCEnergyReportCellModel *cellModel2 = [[MKLFXCEnergyReportCellModel alloc] init];
    cellModel2.msg = @"Power change notification";
    cellModel2.index = 1;
    cellModel2.maxLen = 3;
    cellModel2.noteMsg = @"Range: 1-100, unit: %";
    [self.dataList addObject:cellModel2];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Energy Report Parameters";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCEnergyReportController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKLFXCEnergyReportModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXCEnergyReportModel alloc] init];
    }
    return _dataModel;
}

@end
