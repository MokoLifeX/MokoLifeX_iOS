//
//  MKDeviceInformationController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceInformationController.h"
#import "MKAboutCell.h"
#import "MKAboutModel.h"

@interface MKDeviceInformationController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@end

@implementation MKDeviceInformationController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKDeviceInformationController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedFirmwareInfoNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Device Information";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                   selector:@selector(receiveDeviceFirmware:)
                                       name:MKMQTTServerReceivedFirmwareInfoNotification
                                     object:nil];
    [self initReadTimer];
    // Do any additional setup after loading the view.
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
    MKAboutCell *cell = [MKAboutCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark -
- (void)receiveDeviceFirmware:(NSNotification *)note{
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:self.deviceModel.mqttID]) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedFirmwareInfoNotification object:nil];
    [[MKHudManager share] hide];
    [self getDatasWithInfo:deviceDic];
}

#pragma mark -

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
            [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedFirmwareInfoNotification object:nil];
            [weakSelf.view showCentralToast:@"Get data failed!"];
            [weakSelf performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
        });
    });
    dispatch_resume(self.readTimer);
}

- (void)getDatasWithInfo:(NSDictionary *)infoDic{
    MKAboutModel *companyModel = [[MKAboutModel alloc] init];
    companyModel.leftMsg = @"Company Name";
    companyModel.rightMsg = infoDic[@"company_name"];
    [self.dataList addObject:companyModel];
    
//    MKAboutModel *dateModel = [[MKAboutModel alloc] init];
//    dateModel.leftMsg = @"Date of Manufacture";
//    dateModel.rightMsg = infoDic[@"production_date"];
//    [self.dataList addObject:dateModel];
    
    MKAboutModel *nameModel = [[MKAboutModel alloc] init];
    nameModel.leftMsg = @"Product Model";
    nameModel.rightMsg = infoDic[@"product_model"];
    [self.dataList addObject:nameModel];
    
    MKAboutModel *firmModel = [[MKAboutModel alloc] init];
    firmModel.leftMsg = @"Firmware Version";
    firmModel.rightMsg = infoDic[@"firmware_version"];
    [self.dataList addObject:firmModel];
    
    MKAboutModel *macModel = [[MKAboutModel alloc] init];
    macModel.leftMsg = @"Device Mac";
    macModel.rightMsg = infoDic[@"device_mac"];
    [self.dataList addObject:macModel];
    
    [self.tableView reloadData];
}

#pragma mark - setter & getter
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
