//
//  MKLFXBEnergyController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBEnergyController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UISegmentedControl+MKAdd.h"

#import "MKHudManager.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXEnergyDailyTableView.h"
#import "MKLFXEnergyMonthlyTableView.h"

#import "MKLFXBMQTTInterface.h"
#import "MKLFXBMQTTManager.h"

#import "MKLFXBEnergyDataModel.h"

static CGFloat const segmentWidth = 240.f;
static CGFloat const segmentHeight = 30.f;

#define segmentOffset_Y (defaultTopInset + 20.f)
#define tableViewOffset_Y (segmentOffset_Y + segmentHeight + 5.f)
#define tableViewHeight (kViewHeight - VirtualHomeHeight - tableViewOffset_Y)

@interface MKLFXBEnergyController ()<UIScrollViewDelegate>

@property (nonatomic, strong)UISegmentedControl *segment;

@property (nonatomic, strong)MKLFXEnergyDailyTableView *dailyView;

@property (nonatomic, strong)MKLFXEnergyMonthlyTableView *monthView;

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)NSArray *dailyList;

@property (nonatomic, strong)NSArray *monthlyList;

@property (nonatomic, copy)NSString *pulseConstant;

@property (nonatomic, copy)NSString *totalEnergy;

@property (nonatomic, strong)MKLFXBEnergyDataModel *dataModel;

@property (nonatomic, assign)BOOL isScrolling;

@end

@implementation MKLFXBEnergyController

- (void)dealloc {
    NSLog(@"MKLFXBEnergyController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self addNotifications];
    [self readDataFromServer];
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
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1014) {
        return;
    }
    self.dataModel.monthSuccess = YES;
    NSArray *dateList = [userInfo[@"data"][@"timestamp"] componentsSeparatedByString:@"&"];
    self.monthlyList = [MKLFXBEnergyDataModel parseMonthList:dateList[0] dataList:userInfo[@"data"][@"result"]];
    [self readDataSuccess];
}

- (void)receiveEnergyDataOfToday:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1015) {
        return;
    }
    self.dataModel.dailySuccess = YES;
    self.dailyList = [MKLFXBEnergyDataModel parseDaily:userInfo[@"data"][@"result"]];
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
    [MKLFXBMQTTInterface lfxb_readPulseConstantWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
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
    [MKLFXBMQTTInterface lfxb_readHistoricalEnergyWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
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
    [MKLFXBMQTTInterface lfxb_readEnergyDataOfTodayWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
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
    [MKLFXBMQTTInterface lfxb_readTotalEnergyWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivePulseConstant:)
                                                 name:MKLFXBReceivePulseConstantNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveHistoricalEnergy:)
                                                 name:MKLFXBReceiveHistoricalEnergyNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveEnergyDataOfToday:)
                                                 name:MKLFXBReceiveEnergyDataOfTodayNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTotalEnergy:)
                                                 name:MKLFXBReceiveTotalEnergyNotification
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
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = self.deviceModel.deviceName;
    [self.view addSubview:self.segment];
    [self.segment setFrame:CGRectMake((kViewWidth - segmentWidth) / 2, segmentOffset_Y, segmentWidth, segmentHeight)];
    [self.view addSubview:self.scrollView];
    [self.scrollView setFrame:CGRectMake(0, tableViewOffset_Y, kViewWidth, tableViewHeight)];
    [self.scrollView addSubview:self.dailyView];
    [self.dailyView setFrame:CGRectMake(0, 0, kViewWidth, tableViewHeight)];
    [self.scrollView addSubview:self.monthView];
    [self.monthView setFrame:CGRectMake(kViewWidth, 0, kViewWidth, tableViewHeight)];
}

#pragma mark - getter
- (UISegmentedControl *)segment {
    if (!_segment) {
        _segment = [[UISegmentedControl alloc] initWithItems:@[@"Daily",@"Monthly"]];
        [_segment mk_setTintColor:NAVBAR_COLOR_MACROS];
//        _segment.selectedSegmentTintColor = COLOR_WHITE_MACROS;
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
                                           currentEnergyNotificationName:MKLFXBReceiveCurrentEnergyNotification];
    }
    return _dailyView;
}

- (MKLFXEnergyMonthlyTableView *)monthView {
    if (!_monthView) {
        _monthView = [[MKLFXEnergyMonthlyTableView alloc] initWithDeviceID:self.deviceModel.deviceID
                                             currentEnergyNotificationName:MKLFXBReceiveCurrentEnergyNotification];
    }
    return _monthView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(2 * kViewWidth, 0);
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (MKLFXBEnergyDataModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXBEnergyDataModel alloc] init];
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
