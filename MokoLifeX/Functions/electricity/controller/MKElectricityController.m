//
//  MKElectricityController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKElectricityController.h"
#import "MKElectricityCell.h"
#import "MKElectricityModel.h"

@interface MKElectricityController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKElectricityController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKElectricityController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedElectricityNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Electricity Management";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self loadDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(receiveElectricityData:)
                                       name:MKMQTTServerReceivedElectricityNotification
                                     object:nil];
    // Do any additional setup after loading the view.
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
    MKElectricityCell *cell = [MKElectricityCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - Notification Event
- (void)receiveElectricityData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    if (ValidNum(deviceDic[@"current"])) {
        MKElectricityModel *currentModel = self.dataList[0];
        currentModel.value = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"current"] integerValue]];
    }
    if (ValidNum(deviceDic[@"voltage"])) {
        MKElectricityModel *volModel = self.dataList[1];
        volModel.value = [NSString stringWithFormat:@"%.1f",([deviceDic[@"voltage"] integerValue] * 0.1)];
    }
    if (ValidNum(deviceDic[@"power"])) {
        MKElectricityModel *powerModel = self.dataList[2];
        powerModel.value = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"power"] integerValue]];
    }
    [self.tableView reloadData];
}

#pragma mark - private method
- (void)loadDatas{
    MKElectricityModel *currentModel = [[MKElectricityModel alloc] init];
    currentModel.iconName = @"electricityCurrentIcon";
    currentModel.textMsg = @"Current(mA)";
    currentModel.value = @"0";
    [self.dataList addObject:currentModel];
    
    MKElectricityModel *volModel = [[MKElectricityModel alloc] init];
    volModel.iconName = @"electricityVoltageIcon";
    volModel.textMsg = @"Voltage(V)";
    volModel.value = @"0";
    [self.dataList addObject:volModel];
    
    MKElectricityModel *powerModel = [[MKElectricityModel alloc] init];
    powerModel.iconName = @"electricityPowerIcon";
    powerModel.textMsg = @"Power(W)";
    powerModel.value = @"0";
    [self.dataList addObject:powerModel];
    
    [self.tableView reloadData];
}

#pragma mark - setter & getter
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
        _dataList = [NSMutableArray arrayWithCapacity:3];
    }
    return _dataList;
}

@end
