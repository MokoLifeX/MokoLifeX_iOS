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

@interface MKColorSettingController ()
<UITableViewDelegate,
UITableViewDataSource,
MKColorSettingPickViewDelegate,
MKMeasuredPowerLEDCellDelegate>

@property (nonatomic, strong)MKColorSettingPickView *headerView;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

//@property (nonatomic, strong)MKMeasuredPowerLEDColorModel *colorModel;

@property (nonatomic, assign)mk_ledColorType currentColorType;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadTableDatas];
    [self readColorDatas];
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
    cell.delegate = self;
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

#pragma mark - MKMeasuredPowerLEDCellDelegate
- (void)measuredPowerLEDColorChanged:(NSString *)text row:(NSInteger)row {
    MKMeasuredPowerLEDModel *colorModel = self.dataList[row];
    colorModel.textValue = text;
}

#pragma mark - event method
- (void)confirmButtonPressed {
    if (self.currentColorType == mk_ledColorTransitionSmoothly || self.currentColorType == mk_ledColorTransitionDirectly) {
        BOOL checkSuccess = YES;
        for (MKMeasuredPowerLEDModel *model in self.dataList) {
            if (!ValidStr(model.textValue)) {
                checkSuccess = NO;
                break;
            }
        }
        if (!checkSuccess) {
            [self.view showCentralToast:@"Params cannot be empty"];
            return;
        }
        
        MKMeasuredPowerLEDColorModel *colorModel = [[MKMeasuredPowerLEDColorModel alloc] init];
        MKMeasuredPowerLEDModel *bModel = self.dataList[0];
        colorModel.b_color = [bModel.textValue integerValue];
        MKMeasuredPowerLEDModel *gModel = self.dataList[1];
        colorModel.g_color = [gModel.textValue integerValue];
        MKMeasuredPowerLEDModel *yModel = self.dataList[2];
        colorModel.y_color = [yModel.textValue integerValue];
        MKMeasuredPowerLEDModel *oModel = self.dataList[3];
        colorModel.o_color = [oModel.textValue integerValue];
        MKMeasuredPowerLEDModel *rModel = self.dataList[4];
        colorModel.r_color = [rModel.textValue integerValue];
        MKMeasuredPowerLEDModel *pModel = self.dataList[5];
        colorModel.p_color = [pModel.textValue integerValue];
        [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
        [MKMQTTServerInterface setLEDColor:self.currentColorType colorProtocol:colorModel topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
            [[MKHudManager share] hide];
            [self.view showCentralToast:@"Success"];
        } failedBlock:^(NSError * _Nonnull error) {
            [[MKHudManager share] hide];
            [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface setLEDColor:self.currentColorType colorProtocol:nil topic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - Notification
- (void)receiveMQTTServerDatas:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    [[MKHudManager share] hide];
    dispatch_cancel(self.readTimer);
    self.currentColorType = [deviceDic[@"led_state"] integerValue];
    if (self.currentColorType == mk_ledColorTransitionSmoothly || self.currentColorType == mk_ledColorTransitionDirectly) {
        MKMeasuredPowerLEDColorModel *colorModel = [[MKMeasuredPowerLEDColorModel alloc] init];
        colorModel.b_color = [deviceDic[@"blue"] integerValue];
        colorModel.g_color = [deviceDic[@"green"] integerValue];
        colorModel.y_color = [deviceDic[@"yellow"] integerValue];
        colorModel.o_color = [deviceDic[@"orange"] integerValue];
        colorModel.r_color = [deviceDic[@"red"] integerValue];
        colorModel.p_color = [deviceDic[@"purple"] integerValue];
        [self setupTableDatas:colorModel];
    }
    [self.tableView reloadData];
    [self.headerView updateColorType:self.currentColorType];
}

#pragma mark - private method
- (void)readColorDatas {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKMQTTServerInterface readLEDColorWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.deviceModel.mqttID sucBlock:^{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveMQTTServerDatas:)
                                                     name:MKMQTTServerReceivedLEDColorNotification
                                                   object:nil];
        [self initReadTimer];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
        [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
    }];
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

- (void)loadTableDatas {
    MKMeasuredPowerLEDModel *bModel = [[MKMeasuredPowerLEDModel alloc] init];
    bModel.msg = @"Measured power for blue LED(W)";
    bModel.placeholder = @"100";
    bModel.row = 0;
    [self.dataList addObject:bModel];
    
    MKMeasuredPowerLEDModel *gModel = [[MKMeasuredPowerLEDModel alloc] init];
    gModel.msg = @"Measured power for green LED(W)";
    gModel.placeholder = @"300";
    gModel.row = 1;
    [self.dataList addObject:gModel];
    
    MKMeasuredPowerLEDModel *yModel = [[MKMeasuredPowerLEDModel alloc] init];
    yModel.msg = @"Measured power for yellow LED(W)";
    yModel.placeholder = @"500";
    yModel.row = 2;
    [self.dataList addObject:yModel];
    
    MKMeasuredPowerLEDModel *oModel = [[MKMeasuredPowerLEDModel alloc] init];
    oModel.msg = @"Measured power for orange LED(W)";
    oModel.placeholder = @"1000";
    oModel.row = 3;
    [self.dataList addObject:oModel];
    
    MKMeasuredPowerLEDModel *rModel = [[MKMeasuredPowerLEDModel alloc] init];
    rModel.msg = @"Measured power for red LED(W)";
    rModel.placeholder = @"1800";
    rModel.row = 4;
    [self.dataList addObject:rModel];
    
    MKMeasuredPowerLEDModel *pModel = [[MKMeasuredPowerLEDModel alloc] init];
    pModel.msg = @"Measured power for purple LED(W)";
    pModel.placeholder = @"2600";
    pModel.row = 5;
    [self.dataList addObject:pModel];
}

- (void)setupTableDatas:(MKMeasuredPowerLEDColorModel *)colorModel {
    MKMeasuredPowerLEDModel *bModel = self.dataList[0];
    bModel.textValue = [NSString stringWithFormat:@"%ld",(long)colorModel.b_color];
    MKMeasuredPowerLEDModel *gModel = self.dataList[1];
    gModel.textValue = [NSString stringWithFormat:@"%ld",(long)colorModel.g_color];
    MKMeasuredPowerLEDModel *yModel = self.dataList[2];
    yModel.textValue = [NSString stringWithFormat:@"%ld",(long)colorModel.y_color];
    MKMeasuredPowerLEDModel *oModel = self.dataList[3];
    oModel.textValue = [NSString stringWithFormat:@"%ld",(long)colorModel.o_color];
    MKMeasuredPowerLEDModel *rModel = self.dataList[4];
    rModel.textValue = [NSString stringWithFormat:@"%ld",(long)colorModel.r_color];
    MKMeasuredPowerLEDModel *pModel = self.dataList[5];
    pModel.textValue = [NSString stringWithFormat:@"%ld",(long)colorModel.p_color];
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

//- (MKMeasuredPowerLEDColorModel *)colorModel {
//    if (!_colorModel) {
//        _colorModel = [[MKMeasuredPowerLEDColorModel alloc] init];
//        _colorModel.b_color = @"100";
//        _colorModel.g_color = @"300";
//        _colorModel.y_color = @"500";
//        _colorModel.o_color = @"1000";
//        _colorModel.r_color = @"1800";
//        _colorModel.p_color = @"2600";
//    }
//    return _colorModel;
//}

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
