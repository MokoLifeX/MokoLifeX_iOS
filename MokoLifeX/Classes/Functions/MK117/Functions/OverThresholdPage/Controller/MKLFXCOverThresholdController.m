//
//  MKLFXCOverThresholdController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/11.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCOverThresholdController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"
#import "NSString+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextSwitchCell.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"

#import "MKLFXCOverThresholdCell.h"

#import "MKLFXCOverThresholdModel.h"

@interface MKLFXCOverThresholdController ()<UITableViewDelegate,
UITableViewDataSource,
mk_textSwitchCellDelegate,
MKLFXCOverThresholdCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)MKLFXCOverThresholdModel *dataModel;

@end

@implementation MKLFXCOverThresholdController

- (void)dealloc {
    NSLog(@"MKLFXCOverThresholdController销毁");
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
    [self readDatasFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    if (self.pageType == mk_lfxc_overThresholdType_load) {
        [self configOverLoadValues];
        return;
    }
    if (self.pageType == mk_lfxc_overThresholdType_voltage) {
        [self configOverVoltageValues];
        return;
    }
    if (self.pageType == mk_lfxc_overThresholdType_current) {
        [self configOverCurrentValues];
        return;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44.f;
    }
    return 88.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKTextSwitchCell *cell = [MKTextSwitchCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKLFXCOverThresholdCell *cell = [MKLFXCOverThresholdCell initCellWithTableView:tableView];
    cell.dataModel = self.section1List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - mk_textSwitchCellDelegate
/// 开关状态发生改变了
/// @param isOn 当前开关状态
/// @param index 当前cell所在的index
- (void)mk_textSwitchCellStatusChanged:(BOOL)isOn index:(NSInteger)index {
    MKTextSwitchCellModel *cellModel = self.section0List[index];
    cellModel.isOn = isOn;
    if (index == 0) {
        self.dataModel.isOn = isOn;
        return;
    }
}

#pragma mark - MKLFXCOverThresholdCellDelegate
- (void)lfxc_textValueChanged:(NSString *)text index:(NSInteger)index {
    MKLFXCOverThresholdCellModel *cellModel = self.section1List[index];
    cellModel.textValue = text;
    if (index == 0) {
        self.dataModel.valueThreshold = text;
        return;
    }
    if (index == 1) {
        self.dataModel.timeThreshold = text;
        return;
    }
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
    self.dataModel.readProductModelSuccess = YES;
    [self readDataSuccess];
}

- (void)receiveOverLoadParamsDatas:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1103) {
        return;
    }
    self.dataModel.readOverValueSuccess = YES;
    [self updateOverValues:userInfo floatValue:NO];
    [self readDataSuccess];
}

- (void)receiveOverVoltageParamsDatas:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1107) {
        return;
    }
    self.dataModel.readOverValueSuccess = YES;
    [self updateOverValues:userInfo floatValue:NO];
    [self readDataSuccess];
}

- (void)receiveOverCurrentDatas:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1111) {
        return;
    }
    self.dataModel.readOverValueSuccess = YES;
    [self updateOverValues:userInfo floatValue:YES];
    [self readDataSuccess];
}

#pragma mark - Private method

- (void)readDatasFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    dispatch_async(self.readQueue, ^{
        if (![self readProductModel]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Product Model Error"];
            });
            return;
        }
        if (self.pageType == mk_lfxc_overThresholdType_load) {
            if (![self readOverLoadValues]) {
                moko_dispatch_main_safe(^{
                    [[MKHudManager share] hide];
                    [self.view showCentralToast:@"Read Overload Error"];
                });
                return;
            }
        }
        if (self.pageType == mk_lfxc_overThresholdType_voltage) {
            if (![self readOverVoltageValues]) {
                moko_dispatch_main_safe(^{
                    [[MKHudManager share] hide];
                    [self.view showCentralToast:@"Read Over Voltage Error"];
                });
                return;
            }
        }
        if (self.pageType == mk_lfxc_overThresholdType_current) {
            if (![self readOverCurrentValues]) {
                moko_dispatch_main_safe(^{
                    [[MKHudManager share] hide];
                    [self.view showCentralToast:@"Read Over Current Error"];
                });
                return;
            }
        }
        moko_dispatch_main_safe(^{
            [self startReadTimer];
        });
    });
    
}

- (void)readDataSuccess {
    if (!self.dataModel.readOverValueSuccess || !self.dataModel.readProductModelSuccess) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceInfo:)
                                                 name:MKLFXCReceiveFirmwareInfoNotification
                                               object:nil];
    if (self.pageType == mk_lfxc_overThresholdType_load) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOverLoadParamsDatas:)
                                                     name:MKLFXCReceiveOverLoadParamsNotification
                                                   object:nil];
        return;
    }
    if (self.pageType == mk_lfxc_overThresholdType_voltage) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOverVoltageParamsDatas:)
                                                     name:MKLFXCReceiveOverVoltageParamsNotification
                                                   object:nil];
        return;
    }
    if (self.pageType == mk_lfxc_overThresholdType_current) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveOverCurrentDatas:)
                                                     name:MKLFXCReceiveOverCurrentParamsNotification
                                                   object:nil];
        return;
    }
}

- (void)loadSectionDatas {
    if (self.pageType == mk_lfxc_overThresholdType_load) {
        [self loadLSection0Datas];
        [self loadLSection1Datas];
        [self.tableView reloadData];
        return;
    }
    if (self.pageType == mk_lfxc_overThresholdType_voltage) {
        [self loadVSection0Datas];
        [self loadVSection1Datas];
        [self.tableView reloadData];
        return;
    }
    if (self.pageType == mk_lfxc_overThresholdType_current) {
        [self loadCSection0Datas];
        [self loadCSection1Datas];
        [self.tableView reloadData];
        return;
    }
}

- (void)updateOverValues:(NSDictionary *)userInfo floatValue:(BOOL)floatValue {
    self.dataModel.isOn = ([userInfo[@"data"][@"protection_enable"] integerValue] == 1);
    MKTextSwitchCellModel *cellModel1 = self.section0List[0];
    cellModel1.isOn = self.dataModel.isOn;
    if (floatValue) {
        self.dataModel.valueThreshold = [NSString stringWithFormat:@"%.1f",[userInfo[@"data"][@"protection_value"] floatValue]];
    }else {
        self.dataModel.valueThreshold = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"protection_value"]];
    }
    
    self.dataModel.timeThreshold = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"judge_time"]];
    
    MKLFXCOverThresholdCellModel *cellModel2 = self.section1List[0];
    cellModel2.textValue = self.dataModel.valueThreshold;
    
    MKLFXCOverThresholdCellModel *cellModel3 = self.section1List[1];
    cellModel3.textValue = self.dataModel.timeThreshold;
    
    [self.tableView reloadData];
}

#pragma mark - interface
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

- (BOOL)readOverLoadValues {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readOverLoadParamsWithDeviceID:self.deviceModel.deviceID
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

- (void)configOverLoadValues {
    if (self.dataModel.isOn) {
        if (!ValidStr(self.dataModel.valueThreshold)) {
            [self.view showCentralToast:@"Power threshold cannot be empty"];
            return;
        }
        if (!ValidStr(self.dataModel.timeThreshold)) {
            [self.view showCentralToast:@"Time threshold cannot be empty"];
            return;
        }
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configOverLoadParams:self.dataModel.isOn
                                    powerThreshold:[self.dataModel.valueThreshold integerValue]
                                     timeThreshold:[self.dataModel.timeThreshold integerValue]
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

- (BOOL)readOverVoltageValues {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readOverVoltageParamsWithDeviceID:self.deviceModel.deviceID
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

- (void)configOverVoltageValues {
    if (self.dataModel.isOn) {
        if (!ValidStr(self.dataModel.valueThreshold)) {
            [self.view showCentralToast:@"Voltage threshold cannot be empty"];
            return;
        }
        if (!ValidStr(self.dataModel.timeThreshold)) {
            [self.view showCentralToast:@"Time threshold cannot be empty"];
            return;
        }
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configOverVoltageParams:self.dataModel.isOn
                                     voltageThreshold:[self.dataModel.valueThreshold integerValue]
                                        timeThreshold:[self.dataModel.timeThreshold integerValue]
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

- (BOOL)readOverCurrentValues {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readOverCurrentParamsWithDeviceID:self.deviceModel.deviceID
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

- (void)configOverCurrentValues {
    if (self.dataModel.isOn) {
        if (!ValidStr(self.dataModel.valueThreshold)) {
            [self.view showCentralToast:@"Current threshold cannot be empty"];
            return;
        }
        if (!ValidStr(self.dataModel.timeThreshold)) {
            [self.view showCentralToast:@"Time threshold cannot be empty"];
            return;
        }
    }
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configOverCurrentParams:self.dataModel.isOn
                                     currentThreshold:(NSInteger)([self.dataModel.valueThreshold doubleValue] * 10)
                                        timeThreshold:[self.dataModel.timeThreshold integerValue]
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

#pragma mark - Over-load Threshold
- (void)loadLSection0Datas {
    MKTextSwitchCellModel *cellModel = [[MKTextSwitchCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"Over-load Protection";
    [self.section0List addObject:cellModel];
}

- (void)loadLSection1Datas {
    MKLFXCOverThresholdCellModel *cellModel1 = [[MKLFXCOverThresholdCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Power threshold(W)";
    cellModel1.maxLen = 4;
    cellModel1.placeholder = @"";
    [self.section1List addObject:cellModel1];
    
    MKLFXCOverThresholdCellModel *cellModel2 = [[MKLFXCOverThresholdCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Time threshold(Sec)";
    cellModel2.maxLen = 2;
    cellModel2.placeholder = @"";
    [self.section1List addObject:cellModel2];
}

#pragma mark - Over-voltage Threshold
- (void)loadVSection0Datas {
    MKTextSwitchCellModel *cellModel = [[MKTextSwitchCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"Over-voltage Protection";
    [self.section0List addObject:cellModel];
}

- (void)loadVSection1Datas {
    MKLFXCOverThresholdCellModel *cellModel1 = [[MKLFXCOverThresholdCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Voltage threshold(V)";
    cellModel1.maxLen = 3;
    cellModel1.placeholder = @"";
    [self.section1List addObject:cellModel1];
    
    MKLFXCOverThresholdCellModel *cellModel2 = [[MKLFXCOverThresholdCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Time threshold(Sec)";
    cellModel2.maxLen = 2;
    cellModel2.placeholder = @"";
    [self.section1List addObject:cellModel2];
}

#pragma mark - Over-current Threshold
- (void)loadCSection0Datas {
    MKTextSwitchCellModel *cellModel = [[MKTextSwitchCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"Over-current Protection";
    [self.section0List addObject:cellModel];
}

- (void)loadCSection1Datas {
    MKLFXCOverThresholdCellModel *cellModel1 = [[MKLFXCOverThresholdCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Current threshold(A)";
    cellModel1.placeholder = @"";
    cellModel1.floatType = YES;
    cellModel1.maxLen = 4;
    [self.section1List addObject:cellModel1];
    
    MKLFXCOverThresholdCellModel *cellModel2 = [[MKLFXCOverThresholdCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Time threshold(Sec)";
    cellModel2.maxLen = 2;
    cellModel2.placeholder = @"";
    [self.section1List addObject:cellModel2];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = [self currentTitle];
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCOverThresholdController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
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
        _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = [self footerView];
    }
    return _tableView;
}

- (NSMutableArray *)section0List {
    if (!_section0List) {
        _section0List = [NSMutableArray array];
    }
    return _section0List;
}

- (NSMutableArray *)section1List {
    if (!_section1List) {
        _section1List = [NSMutableArray array];
    }
    return _section1List;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("readOverQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

- (MKLFXCOverThresholdModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXCOverThresholdModel alloc] init];
    }
    return _dataModel;
}

- (UIView *)footerView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 100.f)];
    footerView.backgroundColor = RGBCOLOR(242, 242, 242);
    
    NSString *noteMsg = [self currentNoteMsg];
    CGSize noteSize = [NSString sizeWithText:noteMsg
                                     andFont:MKFont(11.f)
                                  andMaxSize:CGSizeMake(kViewWidth - 2 * 15.f, MAXFLOAT)];
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.f, 10.f, kViewWidth - 2 * 15.f, noteSize.height)];
    msgLabel.textColor = RGBCOLOR(207, 207, 207);
    msgLabel.font = MKFont(11.f);
    msgLabel.textAlignment = NSTextAlignmentLeft;
    msgLabel.numberOfLines = 0;
    msgLabel.text = noteMsg;
    
    [footerView addSubview:msgLabel];
    
    return footerView;
}

- (NSString *)currentTitle {
    switch (self.pageType) {
        case mk_lfxc_overThresholdType_load:
            return @"Over-load Protection";
        case mk_lfxc_overThresholdType_voltage:
            return @"Over-voltage Protection";
        case mk_lfxc_overThresholdType_current:
            return @"Over-current Protection";
    }
}

- (NSString *)currentNoteMsg {
    switch (self.pageType) {
        case mk_lfxc_overThresholdType_load:
            return @"When the measured power exceeds the protection threshold and the duration exceeds the time threshold, the device will turn off automatically.";
        case mk_lfxc_overThresholdType_voltage:
            return @"When the measured voltage exceeds the protection threshold and the duration exceeds the time threshold, the device will turn off automatically.";
        case mk_lfxc_overThresholdType_current:
            return @"When the measured current exceeds the protection threshold and the duration exceeds the time threshold, the device will turn off automatically.";
    }
}

@end
