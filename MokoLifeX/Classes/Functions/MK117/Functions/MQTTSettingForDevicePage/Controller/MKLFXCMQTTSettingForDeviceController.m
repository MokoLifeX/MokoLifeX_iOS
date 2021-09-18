//
//  MKLFXCMQTTSettingForDeviceController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCMQTTSettingForDeviceController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTManager.h"

#import "MKLFXCMQTTSettingForDeviceCell.h"

@interface MKLFXCMQTTSettingForDeviceController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKLFXCMQTTSettingForDeviceController

- (void)dealloc {
    NSLog(@"MKLFXCMQTTSettingForDeviceController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveMQTTParams:)
                                                 name:MKLFXCReceiveDeviceMQTTParamsNotification
                                               object:nil];
    [self readDataFromDevice];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXCMQTTSettingForDeviceCellModel *cellModel = self.dataList[indexPath.row];
    return [cellModel fetchCellHeight];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXCMQTTSettingForDeviceCell *cell = [MKLFXCMQTTSettingForDeviceCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)receiveMQTTParams:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1123) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    MKLFXCMQTTSettingForDeviceCellModel *cellModel1 = self.dataList[0];
    cellModel1.rightMsg = ([userInfo[@"data"][@"connect_mode"] integerValue] == 0 ? @"TCP" : @"SSL");
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel2 = self.dataList[1];
    cellModel2.rightMsg = userInfo[@"data"][@"host"];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel3 = self.dataList[2];
    cellModel3.rightMsg = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"port"]];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel4 = self.dataList[3];
    cellModel4.rightMsg = userInfo[@"data"][@"client_id"];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel5 = self.dataList[4];
    cellModel5.rightMsg = userInfo[@"data"][@"username"];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel6 = self.dataList[5];
    cellModel6.rightMsg = userInfo[@"data"][@"password"];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel7 = self.dataList[6];
    cellModel7.rightMsg = ([userInfo[@"data"][@"clean_session"] integerValue] == 1 ? @"YES" : @"NO");
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel8 = self.dataList[7];
    cellModel8.rightMsg = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"qos"]];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel9 = self.dataList[8];
    cellModel9.rightMsg = [NSString stringWithFormat:@"%@",userInfo[@"data"][@"keepalive"]];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel10 = self.dataList[9];
    cellModel10.rightMsg = userInfo[@"data"][@"device_id"];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel11 = self.dataList[10];
    cellModel11.rightMsg = userInfo[@"data"][@"publish_topic"];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel12 = self.dataList[11];
    cellModel12.rightMsg = userInfo[@"data"][@"subscribe_topic"];
    
    [self.tableView reloadData];
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_readDeviceMQTTParamsWithDeviceID:self.deviceModel.deviceID
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
    MKLFXCMQTTSettingForDeviceCellModel *cellModel1 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel1.msg = @"Type";
    [self.dataList addObject:cellModel1];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel2 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel2.msg = @"Host";
    [self.dataList addObject:cellModel2];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel3 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel3.msg = @"Port";
    [self.dataList addObject:cellModel3];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel4 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel4.msg = @"Client Id";
    [self.dataList addObject:cellModel4];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel5 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel5.msg = @"Username";
    [self.dataList addObject:cellModel5];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel6 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel6.msg = @"Password";
    [self.dataList addObject:cellModel6];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel7 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel7.msg = @"Clean Session";
    [self.dataList addObject:cellModel7];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel8 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel8.msg = @"Qos";
    [self.dataList addObject:cellModel8];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel9 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel9.msg = @"Keep Alive";
    [self.dataList addObject:cellModel9];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel10 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel10.msg = @"Device Id";
    [self.dataList addObject:cellModel10];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel11 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel11.msg = @"Published Topic";
    [self.dataList addObject:cellModel11];
    
    MKLFXCMQTTSettingForDeviceCellModel *cellModel12 = [[MKLFXCMQTTSettingForDeviceCellModel alloc] init];
    cellModel12.msg = @"Subscribed Topic";
    [self.dataList addObject:cellModel12];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Settings for Device";
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
