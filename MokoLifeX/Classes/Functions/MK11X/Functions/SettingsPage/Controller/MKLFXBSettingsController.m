//
//  MKLFXBSettingsController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBSettingsController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKAlertController.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXBMQTTInterface.h"
#import "MKLFXBMQTTManager.h"

#import "MKLFXBSettingsPageCell.h"

#import "MKLFXBColorSettingController.h"
#import "MKLFXBConfigDataController.h"

@interface MKLFXBSettingsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKLFXBSettingsController

- (void)dealloc {
    NSLog(@"MKLFXBSettingsController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [self readDatasFromServer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTotalEnergy:)
                                                 name:MKLFXBReceiveTotalEnergyNotification
                                               object:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //LED color settings
        MKLFXBColorSettingController *vc = [[MKLFXBColorSettingController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 1) {
        //Overload value
        MKLFXBConfigDataController *vc = [[MKLFXBConfigDataController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.pageType = mk_lfxb_configDataPageType_overloadValue;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 2) {
        //Power report period
        MKLFXBConfigDataController *vc = [[MKLFXBConfigDataController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.pageType = mk_lfxb_configDataPageType_powerReport;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 3) {
        //Energy storage parameters
        MKLFXBConfigDataController *vc = [[MKLFXBConfigDataController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.pageType = mk_lfxb_configDataPageType_energyStorage;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 4) {
        //重置电能
        [self resetEnergyConsumption];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXBSettingsPageCell *cell = [MKLFXBSettingsPageCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - notes

- (void)receiveTotalEnergy:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1017) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    
    float pulseConstant = [userInfo[@"data"][@"EC"] floatValue];
    float totalEnery = [userInfo[@"data"][@"all_energy"] floatValue];
    [self updateEnergyValues:pulseConstant totalEnery:totalEnery];
}

#pragma mark - interface
- (void)readDatasFromServer {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_readTotalEnergyWithDeviceID:self.deviceModel.deviceID
                                                    topic:[self.deviceModel currentSubscribedTopic]
                                                 sucBlock:^{
        [self startReadTimer];
    }
                                              failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 重置电能
- (void)resetEnergyConsumption {
    NSString *msg = @"Please confirm again whether to reset energy consumption data. After reset, all energy data will be cleaned.";
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Reset Energy Consumption"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    alertView.notificationName = @"mk_lfxb_dismissAlert";
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertView addAction:cancelAction];
    @weakify(self);
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self energyConsumptionMethod];
    }];
    [alertView addAction:moreAction];
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)energyConsumptionMethod {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_resetAccumulatedEnergyWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        [self updateEnergyValues:1 totalEnery:0];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSectionDatas
- (void)updateEnergyValues:(float)pulseConstant totalEnery:(float)totalEnery {
    if (pulseConstant == 0.0) {
        return;
    }
    float tempValue = totalEnery / pulseConstant;
    NSString *energyConsumption = [NSString stringWithFormat:@"%.2f",tempValue];
    MKLFXBSettingsPageCellModel *cellModel = self.dataList[4];
    cellModel.rightMsg = energyConsumption;
    [self.tableView mk_reloadRow:4 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
}

- (void)loadSectionDatas {
    MKLFXBSettingsPageCellModel *cellModel1 = [[MKLFXBSettingsPageCellModel alloc] init];
    cellModel1.leftMsg = @"LED color settings";
    [self.dataList addObject:cellModel1];
    
    MKLFXBSettingsPageCellModel *cellModel2 = [[MKLFXBSettingsPageCellModel alloc] init];
    cellModel2.leftMsg = @"Overload value";
    [self.dataList addObject:cellModel2];
    
    MKLFXBSettingsPageCellModel *cellModel3 = [[MKLFXBSettingsPageCellModel alloc] init];
    cellModel3.leftMsg = @"Power report period";
    [self.dataList addObject:cellModel3];
    
    MKLFXBSettingsPageCellModel *cellModel4 = [[MKLFXBSettingsPageCellModel alloc] init];
    cellModel4.leftMsg = @"Energy storage parameters";
    [self.dataList addObject:cellModel4];
    
    MKLFXBSettingsPageCellModel *cellModel5 = [[MKLFXBSettingsPageCellModel alloc] init];
    cellModel5.leftMsg = @"Energy consumption(KWh)";
    [self.dataList addObject:cellModel5];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Settings";
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
