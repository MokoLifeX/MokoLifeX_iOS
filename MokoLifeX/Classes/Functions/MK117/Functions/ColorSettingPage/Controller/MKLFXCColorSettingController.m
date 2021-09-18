//
//  MKLFXCColorSettingController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCColorSettingController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTManager.h"

#import "MKLFXCLedColorModel.h"
#import "MKLFXCColorSettingModel.h"

#import "MKLFXCColorSettingPickView.h"
#import "MKLFXCLEDColorCell.h"

@interface MKLFXCColorSettingController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXCColorSettingPickViewDelegate,
MKLFXCLEDColorCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKLFXCColorSettingPickView *tableHeaderView;

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)MKLFXCColorSettingModel *dataModel;

@end

@implementation MKLFXCColorSettingController

- (void)dealloc {
    NSLog(@"MKLFXCColorSettingController销毁");
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
    [self addNotifications];
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
    return (self.dataModel.colorType == mk_lfxc_ledColorTransitionDirectly || self.dataModel.colorType == mk_lfxc_ledColorTransitionSmoothly) ? self.dataList.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXCLEDColorCell *cell = [MKLFXCLEDColorCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKLFXCColorSettingPickViewDelegate
- (void)lfxc_colorSettingPickViewTypeChanged:(NSInteger)colorType {
    if (self.dataModel.colorType == colorType) {
        return;
    }
    self.self.dataModel.colorType = colorType;
    [self.tableView reloadData];
}

#pragma mark - MKLFXCLEDColorCellDelegate
- (void)lfxc_ledColorChanged:(NSString *)value index:(NSInteger)index {
    MKLFXCLEDColorCellModel *cellModel = self.dataList[index];
    cellModel.textValue = value;
}

#pragma mark - note
- (void)receiveDeviceInfo:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1002) {
        return;
    }
    mk_lfxc_productModel productModel = mk_lfxc_productModel_FE;
    if ([userInfo[@"data"][@"product_type"] isEqualToString:@"MK117-B"]) {
        productModel = mk_lfxc_productModel_B;
    }else if ([userInfo[@"data"][@"product_type"] isEqualToString:@"MK117-G"]) {
        productModel = mk_lfxc_productModel_G;
    }
    self.dataModel.productModel = productModel;
    self.dataModel.productModelSuccess = YES;
    [self readDataSuccess];
}

- (void)receiveLEDColor:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1009) {
        return;
    }
    
    self.dataModel.colorType = [userInfo[@"data"][@"led_state"] integerValue];
    self.dataModel.colorDataSuccess = YES;
    
    MKLFXCLEDColorCellModel *bModel = self.dataList[0];
    bModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"blue"]];
    MKLFXCLEDColorCellModel *gModel = self.dataList[1];
    gModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"green"]];
    MKLFXCLEDColorCellModel *yModel = self.dataList[2];
    yModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"yellow"]];
    MKLFXCLEDColorCellModel *oModel = self.dataList[3];
    oModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"orange"]];
    MKLFXCLEDColorCellModel *rModel = self.dataList[4];
    rModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"red"]];
    MKLFXCLEDColorCellModel *pModel = self.dataList[5];
    pModel.textValue = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"purple"]];
    
    [self.tableView reloadData];
    [self.tableHeaderView updateColorType:self.dataModel.colorType];
    
    [self readDataSuccess];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    MKLFXCLedColorModel *colorModel = [[MKLFXCLedColorModel alloc] init];
    MKLFXCLEDColorCellModel *bModel = self.dataList[0];
    colorModel.b_color = [bModel.textValue integerValue];
    MKLFXCLEDColorCellModel *gModel = self.dataList[1];
    colorModel.g_color = [gModel.textValue integerValue];
    MKLFXCLEDColorCellModel *yModel = self.dataList[2];
    colorModel.y_color = [yModel.textValue integerValue];
    MKLFXCLEDColorCellModel *oModel = self.dataList[3];
    colorModel.o_color = [oModel.textValue integerValue];
    MKLFXCLEDColorCellModel *rModel = self.dataList[4];
    colorModel.r_color = [rModel.textValue integerValue];
    MKLFXCLEDColorCellModel *pModel = self.dataList[5];
    colorModel.p_color = [pModel.textValue integerValue];
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_setLEDColor:self.dataModel.colorType
                            colorProtocol:colorModel
                             productModel:self.dataModel.productModel
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
    dispatch_async(self.readQueue, ^{
        if (![self readProductModel]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Product Model Error"];
            });
            return;
        }
        if (![self readLEDColorDatas]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Color Data Error"];
            });
            return;
        }
        moko_dispatch_main_safe(^{
            [self startReadTimer];
        });
    });
}

- (BOOL)readProductModel {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readDeviceFirmwareInformationWithDeviceID:self.deviceModel.deviceID
                                                                  topic:[self.deviceModel currentSubscribedTopic]
                                                               sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                                            failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readLEDColorDatas {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readLEDColorWithDeviceID:self.deviceModel.deviceID
                                                 topic:[self.deviceModel currentSubscribedTopic]
                                              sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    }
                                           failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (void)readDataSuccess {
    if (!self.dataModel.colorDataSuccess || !self.dataModel.productModelSuccess) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
}

#pragma mark - private method
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLEDColor:)
                                                 name:MKLFXCReceiveLEDColorNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceInfo:)
                                                 name:MKLFXCReceiveFirmwareInfoNotification
                                               object:nil];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKLFXCLEDColorCellModel *bModel = [[MKLFXCLEDColorCellModel alloc] init];
    bModel.msg = @"Measured power for blue LED(W)";
    bModel.placeholder = @"";
    bModel.index = 0;
    [self.dataList addObject:bModel];
    
    MKLFXCLEDColorCellModel *gModel = [[MKLFXCLEDColorCellModel alloc] init];
    gModel.msg = @"Measured power for green LED(W)";
    gModel.placeholder = @"";
    gModel.index = 1;
    [self.dataList addObject:gModel];
    
    MKLFXCLEDColorCellModel *yModel = [[MKLFXCLEDColorCellModel alloc] init];
    yModel.msg = @"Measured power for yellow LED(W)";
    yModel.placeholder = @"";
    yModel.index = 2;
    [self.dataList addObject:yModel];
    
    MKLFXCLEDColorCellModel *oModel = [[MKLFXCLEDColorCellModel alloc] init];
    oModel.msg = @"Measured power for orange LED(W)";
    oModel.placeholder = @"";
    oModel.index = 3;
    [self.dataList addObject:oModel];
    
    MKLFXCLEDColorCellModel *rModel = [[MKLFXCLEDColorCellModel alloc] init];
    rModel.msg = @"Measured power for red LED(W)";
    rModel.placeholder = @"";
    rModel.index = 4;
    [self.dataList addObject:rModel];
    
    MKLFXCLEDColorCellModel *pModel = [[MKLFXCLEDColorCellModel alloc] init];
    pModel.msg = @"Measured power for purple LED(W)";
    pModel.placeholder = @"";
    pModel.index = 5;
    [self.dataList addObject:pModel];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Color Settings";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCColorSettingController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
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

- (MKLFXCColorSettingPickView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[MKLFXCColorSettingPickView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 200.f)];
        _tableHeaderView.delegate = self;
    }
    return _tableHeaderView;
}

- (MKLFXCColorSettingModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXCColorSettingModel alloc] init];
    }
    return _dataModel;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("readColorQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
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
