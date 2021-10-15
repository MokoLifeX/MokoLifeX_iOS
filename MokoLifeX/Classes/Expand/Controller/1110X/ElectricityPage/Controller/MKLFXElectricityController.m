//
//  MKLFXElectricityController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXElectricityController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"

#import "MKLFXDeviceModel.h"

@interface MKLFXElectricityController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKLFXElectricityController

- (void)dealloc {
    NSLog(@"MKLFXElectricityController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveElectricityDatas:)
                                                 name:self.electricityNotificationName
                                               object:nil];
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
- (void)receiveElectricityDatas:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1006) {
        return;
    }
    if (ValidNum(userInfo[@"data"][@"current"])) {
        MKNormalTextCellModel *currentModel = self.dataList[0];
        currentModel.rightMsg = [NSString stringWithFormat:@"%ld",(long)[userInfo[@"data"][@"current"] integerValue]];
    }
    if (ValidNum(userInfo[@"data"][@"voltage"])) {
        MKNormalTextCellModel *volModel = self.dataList[1];
        CGFloat voltage = [userInfo[@"data"][@"voltage"] floatValue] * self.voltageCoffe;
        volModel.rightMsg = [NSString stringWithFormat:@"%.1f",voltage];
    }
    if (ValidNum(userInfo[@"data"][@"power"])) {
        MKNormalTextCellModel *powerModel = self.dataList[2];
        powerModel.rightMsg = [NSString stringWithFormat:@"%.1f",[userInfo[@"data"][@"power"] floatValue]];
    }
    [self.tableView reloadData];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKNormalTextCellModel *currentModel = [[MKNormalTextCellModel alloc] init];
    currentModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXElectricityController", @"lfx_electricityCurrentIcon.png");
    currentModel.leftMsg = @"Current(mA)";
    currentModel.rightMsg = @"0";
    [self.dataList addObject:currentModel];
    
    MKNormalTextCellModel *volModel = [[MKNormalTextCellModel alloc] init];
    volModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXElectricityController", @"lfx_electricityVoltageIcon.png");
    volModel.leftMsg = @"Voltage(V)";
    volModel.rightMsg = @"0";
    [self.dataList addObject:volModel];
    
    MKNormalTextCellModel *powerModel = [[MKNormalTextCellModel alloc] init];
    powerModel.leftIcon = LOADICON(@"MokoLifeX", @"MKLFXElectricityController", @"lfx_electricityPowerIcon.png");
    powerModel.leftMsg = @"Power(W)";
    powerModel.rightMsg = @"0";
    [self.dataList addObject:powerModel];
    
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
