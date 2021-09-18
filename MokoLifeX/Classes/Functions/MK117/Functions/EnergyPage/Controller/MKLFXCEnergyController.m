//
//  MKLFXCEnergyController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCEnergyController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UISegmentedControl+MKAdd.h"

#import "MKHudManager.h"
#import "MKAlertController.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXEnergyDailyTableView.h"
#import "MKLFXEnergyMonthlyTableView.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTManager.h"

#import "MKLFXCEnergyDataModel.h"

#import "MKLFXCEnergyTotalView.h"

static CGFloat const segmentWidth = 240.f;
static CGFloat const segmentHeight = 30.f;

#define segmentOffset_Y (defaultTopInset + 20.f)
#define tableViewOffset_Y (segmentOffset_Y + segmentHeight + 5.f)
#define tableViewHeight (kViewHeight - VirtualHomeHeight - tableViewOffset_Y)

@interface MKLFXCEnergyController ()<UIScrollViewDelegate>

@property (nonatomic, strong)UISegmentedControl *segment;

@property (nonatomic, strong)MKLFXEnergyDailyTableView *dailyView;

@property (nonatomic, strong)MKLFXEnergyMonthlyTableView *monthView;

@property (nonatomic, strong)MKLFXCEnergyTotalView *totalView;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)NSArray *dailyList;

@property (nonatomic, strong)NSArray *monthlyList;

@property (nonatomic, copy)NSString *pulseConstant;

@property (nonatomic, copy)NSString *totalEnergy;

@property (nonatomic, strong)MKLFXCEnergyDataModel *dataModel;

@property (nonatomic, assign)BOOL isScrolling;

@end

@implementation MKLFXCEnergyController

- (void)dealloc {
    NSLog(@"MKLFXCEnergyController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotifications];
    [self readDataFromServer];
}

#pragma mark - super method
- (void)rightButtonMethod {
    NSString *msg = @"After reset, all energy data will be deleted, please confirm again whether to reset it？";
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Reset Energy Data"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    alertView.notificationName = @"mk_lfxc_dismissAlert";
    @weakify(self);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self emptyEnergyDatas];
    }];
    [alertView addAction:moreAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isScrolling) {
        return;
    }
    NSInteger index = scrollView.contentOffset.x / kViewWidth;
    if (index == self.segment.selectedSegmentIndex) {
        return;
    }
    [self.segment setSelectedSegmentIndex:index];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isScrolling = NO;
}

#pragma mark - note
- (void)receiveDeviceOverProtectionThreshold:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || ![userInfo[@"deviceID"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    //当前设备处于过载/过流/过压状态
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)receivePulseConstant:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1016) {
        return;
    }
    self.dataModel.pulseSuccess = YES;
    self.pulseConstant = [NSString stringWithFormat:@"%ld",(long)[userInfo[@"data"][@"EC"] integerValue]];
    [self readDataSuccess];
}

- (void)receiveHistoricalEnergy:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1020) {
        return;
    }
    self.dataModel.monthSuccess = YES;
    NSArray *dateList = [userInfo[@"data"][@"start_time"] componentsSeparatedByString:@"&"];
    self.monthlyList = [MKLFXCEnergyDataModel parseMonthList:dateList[0] dataList:userInfo[@"data"][@"result"]];
    [self readDataSuccess];
}

- (void)receiveEnergyDataOfToday:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1015) {
        return;
    }
    self.dataModel.dailySuccess = YES;
    self.dailyList = [MKLFXCEnergyDataModel parseDaily:userInfo[@"data"][@"result"]];
    [self readDataSuccess];
}

- (void)receiveTotalEnergy:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1017) {
        return;
    }
    self.dataModel.totalSuccess = YES;
    self.totalEnergy = [NSString stringWithFormat:@"%ld",(long)[userInfo[@"data"][@"all_energy"] integerValue]];
    [self readDataSuccess];
}

#pragma mark - event method
- (void)segmentValueChanged {
    NSInteger index = self.scrollView.contentOffset.x / kViewWidth;
    if (index == self.segment.selectedSegmentIndex) {
        return;
    }
    self.isScrolling = YES;
    [self.scrollView setContentOffset:CGPointMake(self.segment.selectedSegmentIndex * kViewWidth, 0) animated:YES];
}

#pragma mark - interface
- (void)readDataFromServer {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    dispatch_async(self.readQueue, ^{
        if (![self readPulseConstant]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Pulse Constant Error"];
            });
            return;
        }
        if (![self readMonthlyData]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Monthly Data Error"];
            });
            return;
        }
        if (![self readDailyListData]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Daily List Data Error"];
            });
            return;
        }
        if (![self readTotalEnergyData]) {
            moko_dispatch_main_safe(^{
                [[MKHudManager share] hide];
                [self.view showCentralToast:@"Read Total Energy Data Error"];
            });
            return;
        }
        moko_dispatch_main_safe(^{
            [self startReadTimer];
        });
    });
}

- (BOOL)readPulseConstant {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readPulseConstantWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readMonthlyData {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readHistoricalEnergyWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDailyListData {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readEnergyDataOfTodayWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readTotalEnergyData {
    __block BOOL success = NO;
    [MKLFXCMQTTInterface lfxc_readTotalEnergyWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (void)emptyEnergyDatas {
    [[MKHudManager share] showHUDWithTitle:@"Waiting..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_resetAccumulatedEnergyWithDeviceID:self.deviceModel.deviceID
                                                           topic:[self.deviceModel currentSubscribedTopic]
                                                        sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        self.totalEnergy = @"0";
        self.dailyList = @[];
        self.monthlyList = @[];
        [self.dailyView updateEnergyDatas:self.dailyList pulseConstant:self.pulseConstant];
        [self.monthView updateEnergyDatas:self.monthlyList pulseConstant:self.pulseConstant];
        [self.totalView updateTotalValue:self.totalEnergy];
    }
                                                     failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOverProtectionThreshold:)
                                                 name:@"mk_lfxc_deviceOverProtectionThresholdNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePulseConstant:)
                                                 name:MKLFXCReceivePulseConstantNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveHistoricalEnergy:)
                                                 name:MKLFXCReceiveHistoricalEnergyNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveEnergyDataOfToday:)
                                                 name:MKLFXCReceiveEnergyDataOfTodayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTotalEnergy:)
                                                 name:MKLFXCReceiveTotalEnergyNotification
                                               object:nil];
}

- (void)readDataSuccess {
    if (![self.dataModel success]) {
        return;
    }
    [self cancelTimer];
    [[MKHudManager share] hide];
    [self.dailyView updateEnergyDatas:self.dailyList pulseConstant:self.pulseConstant];
    [self.monthView updateEnergyDatas:self.monthlyList pulseConstant:self.pulseConstant];
    [self.totalView updateTotalValue:self.totalEnergy];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = self.deviceModel.deviceName;
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCEnergyController", @"lfx_deleteIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.segment];
    [self.segment setFrame:CGRectMake((kViewWidth - segmentWidth) / 2, segmentOffset_Y, segmentWidth, segmentHeight)];
    [self.view addSubview:self.scrollView];
    [self.scrollView setFrame:CGRectMake(0, tableViewOffset_Y, kViewWidth, tableViewHeight)];
    [self.scrollView addSubview:self.dailyView];
    [self.dailyView setFrame:CGRectMake(0, 0, kViewWidth, tableViewHeight)];
    [self.scrollView addSubview:self.monthView];
    [self.monthView setFrame:CGRectMake(kViewWidth, 0, kViewWidth, tableViewHeight)];
    [self.scrollView addSubview:self.totalView];
    [self.totalView setFrame:CGRectMake(2 * kViewWidth, 0, kViewWidth, tableViewHeight)];
}

#pragma mark - getter
- (UISegmentedControl *)segment {
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"Daily",@"Monthly",@"Totally"]];
        [_segment mk_setTintColor:NAVBAR_COLOR_MACROS];
        _segment.selectedSegmentIndex = 0;
        [_segment addTarget:self
                     action:@selector(segmentValueChanged)
           forControlEvents:UIControlEventValueChanged];
    }
    return _segment;
}

- (MKLFXEnergyDailyTableView *)dailyView {
    if (!_dailyView) {
        _dailyView = [[MKLFXEnergyDailyTableView alloc] initWithDeviceID:self.deviceModel.deviceID
                                           currentEnergyNotificationName:MKLFXCReceiveCurrentEnergyNotification];
    }
    return _dailyView;
}

- (MKLFXEnergyMonthlyTableView *)monthView {
    if (!_monthView) {
        _monthView = [[MKLFXEnergyMonthlyTableView alloc] initWithDeviceID:self.deviceModel.deviceID
                                             currentEnergyNotificationName:MKLFXCReceiveCurrentEnergyNotification];
    }
    return _monthView;
}

- (MKLFXCEnergyTotalView *)totalView {
    if (!_totalView) {
        _totalView = [[MKLFXCEnergyTotalView alloc] init];
    }
    return _totalView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(3 * kViewWidth, 0);
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (MKLFXCEnergyDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXCEnergyDataModel alloc] init];
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
        _readQueue = dispatch_queue_create("readEnergyQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
