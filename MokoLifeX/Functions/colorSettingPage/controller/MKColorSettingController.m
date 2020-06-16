//
//  MKColorSettingController.m
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKColorSettingController.h"

#import "MKColorSettingPickView.h"
#import "MKMeasuredPowerLEDCell.h"

#import "MKMeasuredPowerLEDModel.h"
#import "MKMeasuredPowerLEDColorModel.h"

@interface MKColorSettingController ()<UITableViewDelegate, UITableViewDataSource, MKColorSettingPickViewDelegate>

@property (nonatomic, strong)MKColorSettingPickView *headerView;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKMeasuredPowerLEDColorModel *colorModel;

@property (nonatomic, assign)mk_ledColorType currentColorType;

@end

@implementation MKColorSettingController

- (void)dealloc {
    NSLog(@"MKColorSettingController销毁");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableDatas];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.currentColorType == mk_ledColorTransitionSmoothly || self.currentColorType == mk_ledColorTransitionDirectly) ? self.dataList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKMeasuredPowerLEDCell *cell = [MKMeasuredPowerLEDCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - MKColorSettingPickViewDelegate
- (void)colorSettingPickViewTypeChanged:(mk_ledColorType)colorType {
    if (self.currentColorType == colorType) {
        return;
    }
    self.currentColorType = colorType;
    [self.tableView reloadData];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    
}

#pragma mark - private method



- (void)loadTableDatas {
    MKMeasuredPowerLEDModel *bModel = [[MKMeasuredPowerLEDModel alloc] init];
    bModel.msg = @"Measured power for blue LED(W)";
    bModel.placeholder = @"100";
    bModel.textValue = self.colorModel.b_color;
    [self.dataList addObject:bModel];
    
    MKMeasuredPowerLEDModel *gModel = [[MKMeasuredPowerLEDModel alloc] init];
    gModel.msg = @"Measured power for green LED(W)";
    gModel.placeholder = @"300";
    gModel.textValue = self.colorModel.g_color;
    [self.dataList addObject:gModel];
    
    MKMeasuredPowerLEDModel *yModel = [[MKMeasuredPowerLEDModel alloc] init];
    yModel.msg = @"Measured power for yellow LED(W)";
    yModel.placeholder = @"500";
    yModel.textValue = self.colorModel.y_color;
    [self.dataList addObject:yModel];
    
    MKMeasuredPowerLEDModel *oModel = [[MKMeasuredPowerLEDModel alloc] init];
    oModel.msg = @"Measured power for orange LED(W)";
    oModel.placeholder = @"1000";
    oModel.textValue = self.colorModel.o_color;
    [self.dataList addObject:oModel];
    
    MKMeasuredPowerLEDModel *rModel = [[MKMeasuredPowerLEDModel alloc] init];
    rModel.msg = @"Measured power for red LED(W)";
    rModel.placeholder = @"1800";
    rModel.textValue = self.colorModel.r_color;
    [self.dataList addObject:rModel];
    
    MKMeasuredPowerLEDModel *pModel = [[MKMeasuredPowerLEDModel alloc] init];
    pModel.msg = @"Measured power for purple LED(W)";
    pModel.placeholder = @"2600";
    pModel.textValue = self.colorModel.p_color;
    [self.dataList addObject:pModel];
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.defaultTitle = @"Color Settings";
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
- (MKColorSettingPickView *)headerView {
    if (!_headerView) {
        _headerView = [[MKColorSettingPickView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200.f)];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKMeasuredPowerLEDColorModel *)colorModel {
    if (!_colorModel) {
        _colorModel = [[MKMeasuredPowerLEDColorModel alloc] init];
        _colorModel.b_color = @"100";
        _colorModel.g_color = @"300";
        _colorModel.y_color = @"500";
        _colorModel.o_color = @"1000";
        _colorModel.r_color = @"1800";
        _colorModel.p_color = @"2600";
    }
    return _colorModel;
}

- (UIView *)tableFooterView {
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100.f)];
    UIButton *confirmButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Confirm"
                                                                       target:self
                                                                       action:@selector(confirmButtonPressed)];
    confirmButton.frame = CGRectMake((kScreenWidth - 200) / 2, 30.f, 200, 45.f);
    [footView addSubview:confirmButton];
    return footView;
}

@end
