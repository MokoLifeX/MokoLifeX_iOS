//
//  MKLFXCSystemTimeController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSystemTimeController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTableSectionLineHeader.h"
#import "MKCustomUIAdopter.h"
#import "MKNormalTextCell.h"
#import "MKTextButtonCell.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTManager.h"

#import "MKLFXCSystemTimeCell.h"

#import "MKLFXCNTPConfigController.h"

@interface MKLFXCSystemTimeController ()<UITableViewDelegate,
UITableViewDataSource,
MKLFXCSystemTimeCellDelegate,
MKTextButtonCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *headerList;

@property (nonatomic, strong)UILabel *timeLabel;

@property (nonatomic, strong)dispatch_source_t readDateTimer;

@property (nonatomic, strong)NSArray *timeZoneList;

@property (nonatomic, assign)NSInteger timeZone;

@end

@implementation MKLFXCSystemTimeController

- (void)dealloc {
    NSLog(@"MKLFXCSystemTimeController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.readDateTimer) {
        dispatch_cancel(self.readDateTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceTime:)
                                                 name:MKLFXCReceiveDeviceCurrentTimeNotification
                                               object:nil];
    [self startDeviceTimeTimer];
    [self readTimeFromDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.f;
    }
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        MKLFXCNTPConfigController *vc = [[MKLFXCNTPConfigController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.section0List.count;
    }
    if (section == 1) {
        return self.section1List.count;
    }
    if (section == 2) {
        return self.section2List.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        return cell;
    }
    if (indexPath.section == 1) {
        MKLFXCSystemTimeCell *cell = [MKLFXCSystemTimeCell initCellWithTableView:tableView];
        cell.dataModel = self.section1List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKTextButtonCell *cell = [MKTextButtonCell initCellWithTableView:tableView];
    cell.dataModel = self.section2List[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MKTableSectionLineHeader *headerView = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    headerView.headerModel = self.headerList[section];
    return headerView;
}

#pragma mark - MKLFXCSystemTimeCellDelegate
- (void)lfxc_syncTimeFromPhone {
    [self configDeviceTimeWithTimeZone:self.timeZone];
}

#pragma mark - MKTextButtonCellDelegate
/// 右侧按钮点击触发的回调事件
/// @param index 当前cell所在的index
/// @param dataListIndex 点击按钮选中的dataList里面的index
/// @param value dataList[dataListIndex]
- (void)mk_loraTextButtonCellSelected:(NSInteger)index
                        dataListIndex:(NSInteger)dataListIndex
                                value:(NSString *)value {
    [self configDeviceTimeWithTimeZone:(dataListIndex - 24)];
}

#pragma mark - note
- (void)receiveDeviceTime:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1122) {
        return;
    }
    self.timeZone = [userInfo[@"data"][@"time_zone"] integerValue];
    MKTextButtonCellModel *cellModel = self.section2List[0];
    cellModel.dataListIndex = self.timeZone + 24;
    [self.tableView mk_reloadSection:2 withRowAnimation:UITableViewRowAnimationNone];
    NSString *timeZoneMsg = self.timeZoneList[self.timeZone + 24];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ %@",userInfo[@"data"][@"timestamp"],timeZoneMsg];
}

#pragma mark - interface
- (void)configDeviceTimeWithTimeZone:(NSInteger)timeZone {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_configDeviceTimeZone:timeZone
                                          deviceID:self.deviceModel.deviceID
                                             topic:[self.deviceModel currentSubscribedTopic]
                                          sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
        self.timeZone = timeZone;
        [self readTimeFromDevice];
    }
                                       failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - private method
- (void)startDeviceTimeTimer {
    @weakify(self);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.readDateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.readDateTimer, dispatch_time(DISPATCH_TIME_NOW, 30.0 * NSEC_PER_SEC), 30 * NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(self.readDateTimer, ^{
        @strongify(self);
        moko_dispatch_main_safe(^{
            [self readTimeFromDevice];
        });
    });
    dispatch_resume(self.readDateTimer);
}

- (void)readTimeFromDevice {
    [MKLFXCMQTTInterface lfxc_readDeviceTimeWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        
    } failedBlock:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas];
    
    for (NSInteger i = 0; i < 3; i ++) {
        MKTableSectionLineHeaderModel *headerModel = [[MKTableSectionLineHeaderModel alloc] init];
        [self.headerList addObject:headerModel];
    }
    
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKNormalTextCellModel *cellModel = [[MKNormalTextCellModel alloc] init];
    cellModel.leftMsg = @"Sync Time From NTP";
    cellModel.showRightIcon = YES;
    [self.section0List addObject:cellModel];
}

- (void)loadSection1Datas {
    MKLFXCSystemTimeCellModel *cellModel = [[MKLFXCSystemTimeCellModel alloc] init];
    cellModel.msg = @"Sync Time From Phone";
    cellModel.buttonTitle = @"Sync";
    [self.section1List addObject:cellModel];
}

- (void)loadSection2Datas {
    MKTextButtonCellModel *cellModel = [[MKTextButtonCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"TimeZone";
    cellModel.dataList = self.timeZoneList;
    [self.section2List addObject:cellModel];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"System time";
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
        _tableView.tableFooterView = [self tableViewFooter];
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

- (NSMutableArray *)section2List {
    if (!_section2List) {
        _section2List = [NSMutableArray array];
    }
    return _section2List;
}

- (NSMutableArray *)headerList {
    if (!_headerList) {
        _headerList = [NSMutableArray array];
    }
    return _headerList;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = UIColorFromRGB(0xcccccc);
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = MKFont(13.f);
        _timeLabel.numberOfLines = 0;
    }
    return _timeLabel;
}

- (NSArray *)timeZoneList {
    if (!_timeZoneList) {
        _timeZoneList = @[@"UTC-12:00",@"UTC-12:30",@"UTC-11:00",@"UTC-11:30",@"UTC-10:00",@"UTC-10:30",
                          @"UTC-09:00",@"UTC-09:30",@"UTC-08:00",@"UTC-08:30",@"UTC-07:00",@"UTC-07:30",
                          @"UTC-06:00",@"UTC-06:30",@"UTC-05:00",@"UTC-05:30",@"UTC-04:00",@"UTC-04:30",
                          @"UTC-03:00",@"UTC-03:30",@"UTC-02:00",@"UTC-02:30",@"UTC-01:00",@"UTC-01:30",
                          @"UTC+00:00",@"UTC+00:30",@"UTC+01:00",@"UTC+01:30",@"UTC+02:00",@"UTC+02:30",
                          @"UTC+03:00",@"UTC+03:30",@"UTC+04:00",@"UTC+04:30",@"UTC+05:00",@"UTC+05:30",
                          @"UTC+06:00",@"UTC+06:30",@"UTC+07:00",@"UTC+07:30",@"UTC+08:00",@"UTC+08:30",
                          @"UTC+09:00",@"UTC+09:30",@"UTC+10:00",@"UTC+10:30",@"UTC+11:00",@"UTC+11:30",
                          @"UTC+12:00",@"UTC+12:30"];
    }
    return _timeZoneList;
}

- (UIView *)tableViewFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 100.f)];
    footerView.backgroundColor = RGBCOLOR(242, 242, 242);
    
    [footerView addSubview:self.timeLabel];
    [self.timeLabel setFrame:CGRectMake(15.f, 20.f, kViewWidth - 2 * 15.f, MKFont(13.f).lineHeight)];
    
    return footerView;
}

@end
