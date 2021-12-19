//
//  MKLFXCPowerOnStatusController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCPowerOnStatusController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKLFXPowerOnStatusCell.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"


@interface MKLFXCPowerOnStatusController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKLFXCPowerOnStatusController

- (void)dealloc {
    NSLog(@"MKLFXCPowerOnStatusController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePowerOnStatus:)
                                                 name:MKLFXCReceiveDevicePowerOnStatusNotification
                                               object:nil];
    [self loadSectionDatas];
    [self readDataFromDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configDevicePowerOnStatus:indexPath.row
                                               deviceID:self.deviceModel.deviceID
                                                  topic:[self.deviceModel currentSubscribedTopic]
                                               sucBlock:^{
        [[MKHudManager share] hide];
        [self updateCellDatasWithIndex:indexPath.row];
    }
                                            failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXPowerOnStatusCell *cell = [MKLFXPowerOnStatusCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)receivePowerOnStatus:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1008) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    NSInteger index = [userInfo[@"data"][@"default_status"] integerValue];
    [self updateCellDatasWithIndex:index];
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_readDevicePowerOnStatusWithDeviceID:self.deviceModel.deviceID
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
- (void)updateCellDatasWithIndex:(NSInteger)index {
    for (NSInteger i = 0; i < self.dataList.count; i ++) {
        MKLFXPowerOnStatusCellModel *cellModel = self.dataList[i];
        if (i == index) {
            cellModel.icon = LOADICON(@"MokoLifeX", @"MKLFXCPowerOnStatusController", @"lfx_connectModeSelectedIcon.png");
        }else {
            cellModel.icon = LOADICON(@"MokoLifeX", @"MKLFXCPowerOnStatusController", @"lfx_connectModeUnselectedIcon.png");
        }
    }
    [self.tableView reloadData];
}

- (void)loadSectionDatas {
    MKLFXPowerOnStatusCellModel *cellModel1 = [[MKLFXPowerOnStatusCellModel alloc] init];
    cellModel1.msg = @"OFF";
    cellModel1.icon = LOADICON(@"MokoLifeX", @"MKLFXCPowerOnStatusController", @"lfx_connectModeSelectedIcon.png");
    [self.dataList addObject:cellModel1];
    
    MKLFXPowerOnStatusCellModel *cellModel2 = [[MKLFXPowerOnStatusCellModel alloc] init];
    cellModel2.msg = @"ON";
    cellModel2.icon = LOADICON(@"MokoLifeX", @"MKLFXCPowerOnStatusController", @"lfx_connectModeUnselectedIcon.png");
    [self.dataList addObject:cellModel2];
    
    MKLFXPowerOnStatusCellModel *cellModel3 = [[MKLFXPowerOnStatusCellModel alloc] init];
    cellModel3.msg = @"Restore Last Mode";
    cellModel3.icon = LOADICON(@"MokoLifeX", @"MKLFXCPowerOnStatusController", @"lfx_connectModeUnselectedIcon.png");
    [self.dataList addObject:cellModel3];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Power On Default Mode";
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
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
