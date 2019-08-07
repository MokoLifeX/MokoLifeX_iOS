//
//  MKUpdateFirmwareController.m
//  MKSmartPlug
//
//  Created by aa on 2018/8/20.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKUpdateFirmwareController.h"
#import "MKUpdateFirmwareHostTypeCell.h"
#import "MKUpdateFirmwareCell.h"
#import "MKBaseTableView.h"

NSString *const deviceMacAddress = @"deviceMacAddress";

@interface MKUpdateFirmwareController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKUpdateFirmwareController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKUpdateFirmwareController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedUpdateResultNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Check Firmware Update";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
    [self loadDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        MKUpdateFirmwareHostTypeCell *cell = [MKUpdateFirmwareHostTypeCell initCellWithTable:tableView];
        return cell;
    }
    MKUpdateFirmwareCell *cell = [MKUpdateFirmwareCell initCellWithTable:tableView];
    cell.msg = self.dataList[indexPath.row - 1];
    cell.indexPath = indexPath;
    return cell;
}

#pragma mark - event method
- (void)startUpdatePressed{
    MKUpdateFirmwareCell *hostCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSString *host = [hostCell currentValue];
    if (![host regularExpressions:isUrl] && ![host regularExpressions:isIPAddress]) {
        //host校验错误
        [self.view showCentralToast:@"Host error"];
        return;
    }
    MKUpdateFirmwareCell *portCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *port = [portCell currentValue];
    if (!ValidStr(port)) {
        [self.view showCentralToast:@"Port error"];
        return ;
    }
    if ([port integerValue] < 0 || [port integerValue] > 65535) {
        //port错误
        [self.view showCentralToast:@"Port range : 0~65535"];
        return;
    }
    MKUpdateFirmwareCell *catalogueCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    NSString *catalogue = [catalogueCell currentValue];
    if (!ValidStr(catalogue)) {
        [self.view showCentralToast:@"Catalogue error"];
        return ;
    }
//    MKUpdateFirmwareHostTypeCell *typeCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [[MKHudManager share] showHUDWithTitle:@"Updating..." inView:self.view isPenetration:NO];
    WS(weakSelf);//发送成功订阅升级结果主题
    [MKMQTTServerInterface updateFile:MKUpdateFirmware host:host port:[port integerValue] catalogue:catalogue topic:self.deviceModel.subscribedTopic sucBlock:^{
        //监听升级结果
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(firmwareUpdateResult:)
                                                     name:MKMQTTServerReceivedUpdateResultNotification
                                                   object:nil];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        [weakSelf.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - note
- (void)firmwareUpdateResult:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_id]) {
        return;
    }
    //固件升级结果
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MKMQTTServerReceivedUpdateResultNotification object:nil];
    [[MKHudManager share] hide];
    if ([deviceDic[@"ota_result"] isEqualToString:@"R1"]) {
        //升级成功
        [self.view showCentralToast:@"Update Success!"];
        return;
    }
    //升级失败
    [self.view showCentralToast:@"Update Failed!"];
}

#pragma mark - loadDatas
- (void)loadDatas{
    [self.dataList addObject:@"Host"];
    [self.dataList addObject:@"Port"];
    [self.dataList addObject:@"Catalogue"];
    [self.tableView reloadData];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self tableFooter];
    }
    return _tableView;
}

- (UIView *)tableFooter{
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200.f)];
    tableFooter.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *saveButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Start Update"
                                                                    target:self
                                                                    action:@selector(startUpdatePressed)];
    [tableFooter addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.width.mas_equalTo(kScreenWidth - 2 * 58);
        make.bottom.mas_equalTo(-75.f);
        make.height.mas_equalTo(50.f);
    }];
    return tableFooter;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
