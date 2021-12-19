//
//  MKLFXCElectricityController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCElectricityController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"

@interface MKLFXCElectricityController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKLFXCElectricityController

- (void)dealloc {
    NSLog(@"MKLFXCElectricityController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [self addNotification];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - notes
- (void)receiveDeviceOverProtectionThreshold:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || ![userInfo[@"deviceID"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //当前设备处于过载/过流/过压状态
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)receiveElectricityDatas:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    if (ValidNum(userInfo[@"data"][@"current"])) {
        MKNormalTextCellModel *currentModel = self.dataList[0];
        currentModel.rightMsg = [NSString stringWithFormat:@"%.1f",[userInfo[@"data"][@"current"] floatValue]];
    }
    if (ValidNum(userInfo[@"data"][@"voltage"])) {
        MKNormalTextCellModel *volModel = self.dataList[1];
        CGFloat voltage = [userInfo[@"data"][@"voltage"] floatValue];
        volModel.rightMsg = [NSString stringWithFormat:@"%.1f",voltage];
    }
    if (ValidNum(userInfo[@"data"][@"power"])) {
        MKNormalTextCellModel *powerModel = self.dataList[2];
        powerModel.rightMsg = [NSString stringWithFormat:@"%.1f",[userInfo[@"data"][@"power"] floatValue]];
    }
    if (ValidNum(userInfo[@"data"][@"power_factor"])) {
        MKNormalTextCellModel *factorModel = self.dataList[3];
        factorModel.rightMsg = [NSString stringWithFormat:@"%.3f",[userInfo[@"data"][@"power_factor"] floatValue] * 0.001];
    }
    [self.tableView reloadData];
}

#pragma mark - private method
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOverProtectionThreshold:)
                                                 name:@"mk_lfxc_deviceOverProtectionThresholdNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveElectricityDatas:)
                                                 name:MKLFXCReceiveElectricityNotification
                                               object:nil];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKNormalTextCellModel *currentModel = [[MKNormalTextCellModel alloc] init];
    currentModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXCElectricityController", @"lfx_electricityCurrentIcon.png");
    currentModel.leftMsg = @"Current(mA)";
    currentModel.rightMsg = @"0";
    [self.dataList addObject:currentModel];
    
    MKNormalTextCellModel *volModel = [[MKNormalTextCellModel alloc] init];
    volModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXCElectricityController", @"lfx_electricityVoltageIcon.png");
    volModel.leftMsg = @"Voltage(V)";
    volModel.rightMsg = @"0";
    [self.dataList addObject:volModel];
    
    MKNormalTextCellModel *powerModel = [[MKNormalTextCellModel alloc] init];
    powerModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXCElectricityController", @"lfx_electricityPowerIcon.png");
    powerModel.leftMsg = @"Power(W)";
    powerModel.rightMsg = @"0";
    [self.dataList addObject:powerModel];
    
    MKNormalTextCellModel *factorModel = [[MKNormalTextCellModel alloc] init];
    factorModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXCElectricityController", @"lfx_electricityPowerFactorIcon.png");
    factorModel.leftMsg = @"Power Factor";
    factorModel.rightMsg = @"0.0";
    [self.dataList addObject:factorModel];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Electricity Management";
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
