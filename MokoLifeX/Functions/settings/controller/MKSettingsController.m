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

@end

@implementation MKSettingsController

- (void)dealloc {
    NSLog(@"MKSettingsController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableList];
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
        return;
    }
    MKEPParamsSettingController *vc = [[MKEPParamsSettingController alloc] init];
    vc.configType = indexPath.row - 1;
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updatePropertyWithModel:self.deviceModel];
    model.plugState = self.deviceModel.plugState;
    vc.deviceModel = model;
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

#pragma mark - private method
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
