//
//  MKSettingsController.m
//  MokoLifeX
//
//  Created by aa on 2020/6/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKSettingsController.h"

#import "MKSettingPageCell.h"

#import "MKSettingPageCellModel.h"

#import "MKColorSettingController.h"
#import "MKEPParamsSettingController.h"

@interface MKSettingsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

/// 是否是正在请求数据
@property (nonatomic, assign)BOOL isLoading;

/// 一共两条数据。脉冲场数和总电能数据
@property (nonatomic, assign)NSInteger dataCount;

/// 脉冲场数
@property (nonatomic, copy)NSString *pulseConstant;

/// 总电能数据
@property (nonatomic, copy)NSString *totalEnergy;

@end

@implementation MKSettingsController

- (void)dealloc {
    NSLog(@"MKSettingsController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableList];
    [self readDatasFromServer];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //led color
        MKColorSettingController *vc = [[MKColorSettingController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == self.dataList.count - 1) {
        //最后一个是清空计电量
        [self resetEnergyConsumptionAlert];
        return;
    }
    MKEPParamsSettingController *vc = [[MKEPParamsSettingController alloc] init];
    vc.configType = indexPath.row - 1;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKSettingPageCell *cell = [MKSettingPageCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - notes
- (void)receiveServerData:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    if (self.isLoading) {
        if ([deviceDic[@"function"] integerValue] == 1016) {
            //脉冲常数
            self.dataCount ++;
            self.pulseConstant = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"EC"] integerValue]];
            [self receiveDataSuccess];
            return;
        }
        if ([deviceDic[@"function"] integerValue] == 1017) {
            //总累计电能
            self.dataCount ++;
            self.totalEnergy = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"all_energy"] integerValue]];
            [self receiveDataSuccess];
            return;
        }
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1016) {
        //脉冲常数
        self.pulseConstant = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"EC"] integerValue]];
        [self reloadTotalEnergyCellData];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1017) {
        //总累计电能
        self.totalEnergy = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"all_energy"] integerValue]];
        [self reloadTotalEnergyCellData];
        return;
    }
}

#pragma mark - interface
- (void)readDatasFromServer {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    self.isLoading = YES;
    [MKMQTTServerInterface readPulseConstantWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        
    } failedBlock:^(NSError * _Nonnull error) {
        
    }];
    [MKMQTTServerInterface readTotalEnergyWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        
    } failedBlock:^(NSError * _Nonnull error) {
        
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveServerData:)
                                                 name:MKMQTTServerReceivedPulseConstantNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveServerData:)
                                                 name:MKMQTTServerReceivedTotalEnergyNotification
                                               object:nil];
    [self initReadTimer];
}

#pragma mark - private method
- (void)resetEnergyConsumptionAlert {
    NSString *msg = @"Please confirmalue again whether to reset the accumulated energy value? Value will be recounted after reset.";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reset Energy Consumption"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    WS(weakSelf);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf resetEnergyConsumptionMethod];
    }];
    [alertController addAction:moreAction];
    
    [kAppRootController presentViewController:alertController animated:YES completion:nil];
}

- (void)resetEnergyConsumptionMethod {
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface resetDeviceWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        self.totalEnergy = @"0";
        [self reloadTotalEnergyCellData];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)loadTableList {
    MKSettingPageCellModel *ledSettingModel = [[MKSettingPageCellModel alloc] init];
    ledSettingModel.leftMsg = @"LED color settings";
    [self.dataList addObject:ledSettingModel];
    
    MKSettingPageCellModel *overloadModel = [[MKSettingPageCellModel alloc] init];
    overloadModel.leftMsg = @"Overload value";
    [self.dataList addObject:overloadModel];
    
    MKSettingPageCellModel *powerReportModel = [[MKSettingPageCellModel alloc] init];
    powerReportModel.leftMsg = @"Power report period";
    [self.dataList addObject:powerReportModel];
    
    MKSettingPageCellModel *powerChangeModel = [[MKSettingPageCellModel alloc] init];
    powerChangeModel.leftMsg = @"Energy report period";
    [self.dataList addObject:powerChangeModel];
    
    MKSettingPageCellModel *energyStorageModel = [[MKSettingPageCellModel alloc] init];
    energyStorageModel.leftMsg = @"Energy storage parameters";
    [self.dataList addObject:energyStorageModel];
    
    MKSettingPageCellModel *energyConModel = [[MKSettingPageCellModel alloc] init];
    energyConModel.leftMsg = @"Energy consumption(KWh)";
    [self.dataList addObject:energyConModel];
    
    [self.tableView reloadData];
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

- (void)receiveDataSuccess {
    if (self.dataCount < 2 || self.readTimeout || !self.isLoading) {
        return;
    }
    [[MKHudManager share] hide];
    dispatch_cancel(self.readTimer);
    self.isLoading = NO;
    [self reloadTotalEnergyCellData];
}

- (void)reloadTotalEnergyCellData {
    if ([self.pulseConstant floatValue] == 0) {
        return;
    }
    float tempValue = [self.totalEnergy floatValue] / [self.pulseConstant floatValue];
    NSString *energyConsumption = [NSString stringWithFormat:@"%.2f",tempValue];
    MKSettingPageCellModel *energyConModel = self.dataList.lastObject;
    energyConModel.valueMsg = energyConsumption;
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.defaultTitle = @"Settings";
    self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
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

@end
