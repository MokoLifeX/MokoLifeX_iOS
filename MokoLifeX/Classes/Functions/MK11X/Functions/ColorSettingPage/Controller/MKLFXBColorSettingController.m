//
//  MKLFXBColorSettingController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBColorSettingController.h"

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

#import "MKLFXBLedColorModel.h"

#import "MKLFXBColorSettingPickView.h"
#import "MKLFXBLEDColorCell.h"

@interface MKLFXBColorSettingController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXBColorSettingPickViewDelegate,
MKLFXBLEDColorCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKLFXBColorSettingPickView *tableHeaderView;

@property (nonatomic, assign)NSInteger currentColorType;

@end

@implementation MKLFXBColorSettingController

- (void)dealloc {
    NSLog(@"MKLFXBColorSettingController销毁");
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLEDColor:)
                                                 name:MKLFXBReceiveLEDColorNotification
                                               object:nil];
    [self readDataFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self confirmButtonPressed];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.currentColorType == 0 || self.currentColorType == 1) ? self.dataList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXBLEDColorCell *cell = [MKLFXBLEDColorCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKLFXBColorSettingPickViewDelegate
- (void)lfxb_colorSettingPickViewTypeChanged:(NSInteger)colorType {
    if (self.currentColorType == colorType) {
        return;
    }
    self.currentColorType = colorType;
    [self.tableView reloadData];
}

#pragma mark - MKLFXBLEDColorCellDelegate
- (void)lfxb_ledColorChanged:(NSString *)value index:(NSInteger)index {
    MKLFXBLEDColorCellModel *cellModel = self.dataList[index];
    cellModel.textValue = value;
}

#pragma mark - note
- (void)receiveLEDColor:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1009) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    
    self.currentColorType = [userInfo[@"data"][@"led_state"] integerValue];
    
    MKLFXBLEDColorCellModel *bModel = self.dataList[0];
    bModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"blue"]];
    MKLFXBLEDColorCellModel *gModel = self.dataList[1];
    gModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"green"]];
    MKLFXBLEDColorCellModel *yModel = self.dataList[2];
    yModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"yellow"]];
    MKLFXBLEDColorCellModel *oModel = self.dataList[3];
    oModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"orange"]];
    MKLFXBLEDColorCellModel *rModel = self.dataList[4];
    rModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"red"]];
    MKLFXBLEDColorCellModel *pModel = self.dataList[5];
    pModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"purple"]];
    
    [self.tableView reloadData];
    [self.tableHeaderView updateColorType:self.currentColorType];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    MKLFXBLedColorModel *colorModel = [[MKLFXBLedColorModel alloc] init];
    MKLFXBLEDColorCellModel *bModel = self.dataList[0];
    colorModel.b_color = [bModel.textValue integerValue];
    MKLFXBLEDColorCellModel *gModel = self.dataList[1];
    colorModel.g_color = [gModel.textValue integerValue];
    MKLFXBLEDColorCellModel *yModel = self.dataList[2];
    colorModel.y_color = [yModel.textValue integerValue];
    MKLFXBLEDColorCellModel *oModel = self.dataList[3];
    colorModel.o_color = [oModel.textValue integerValue];
    MKLFXBLEDColorCellModel *rModel = self.dataList[4];
    colorModel.r_color = [rModel.textValue integerValue];
    MKLFXBLEDColorCellModel *pModel = self.dataList[5];
    colorModel.p_color = [pModel.textValue integerValue];
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_setLEDColor:self.currentColorType
                            colorProtocol:colorModel
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

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXBMQTTInterface lfxb_readLEDColorWithDeviceID:self.deviceModel.deviceID
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
    MKLFXBLEDColorCellModel *bModel = [[MKLFXBLEDColorCellModel alloc] init];
    bModel.msg = @"Measured power for blue LED(W)";
    bModel.placeholder = @"";
    bModel.index = 0;
    [self.dataList addObject:bModel];
    
    MKLFXBLEDColorCellModel *gModel = [[MKLFXBLEDColorCellModel alloc] init];
    gModel.msg = @"Measured power for green LED(W)";
    gModel.placeholder = @"";
    gModel.index = 1;
    [self.dataList addObject:gModel];
    
    MKLFXBLEDColorCellModel *yModel = [[MKLFXBLEDColorCellModel alloc] init];
    yModel.msg = @"Measured power for yellow LED(W)";
    yModel.placeholder = @"";
    yModel.index = 2;
    [self.dataList addObject:yModel];
    
    MKLFXBLEDColorCellModel *oModel = [[MKLFXBLEDColorCellModel alloc] init];
    oModel.msg = @"Measured power for orange LED(W)";
    oModel.placeholder = @"";
    oModel.index = 3;
    [self.dataList addObject:oModel];
    
    MKLFXBLEDColorCellModel *rModel = [[MKLFXBLEDColorCellModel alloc] init];
    rModel.msg = @"Measured power for red LED(W)";
    rModel.placeholder = @"";
    rModel.index = 4;
    [self.dataList addObject:rModel];
    
    MKLFXBLEDColorCellModel *pModel = [[MKLFXBLEDColorCellModel alloc] init];
    pModel.msg = @"Measured power for purple LED(W)";
    pModel.placeholder = @"";
    pModel.index = 5;
    [self.dataList addObject:pModel];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Color Settings";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXBColorSettingController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
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
        _tableView.tableHeaderView = self.tableHeaderView;
//        _tableView.tableFooterView = [self tableFooterView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKLFXBColorSettingPickView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[MKLFXBColorSettingPickView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 200.f)];
        _tableHeaderView.delegate = self;
    }
    return _tableHeaderView;
}

- (UIView *)tableFooterView {
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 60.f)];
    tableFooterView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *confirmButton = [MKCustomUIAdopter customButtonWithTitle:@"Confirm"
                                                                target:self
                                                                action:@selector(confirmButtonPressed)];
    confirmButton.frame = CGRectMake(30.f, 10.f, kViewWidth - 2 * 30.f, 40.f);
    [tableFooterView addSubview:confirmButton];
    
    return tableFooterView;
}

@end
