//
//  MKLFXCLoadStatusController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCLoadStatusController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextSwitchCell.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"

#import "MKLFXCLoadStatusModel.h"

@interface MKLFXCLoadStatusController ()<UITableViewDelegate,
UITableViewDataSource,
mk_textSwitchCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKLFXCLoadStatusModel *dataModel;

@end

@implementation MKLFXCLoadStatusController

- (void)dealloc {
    NSLog(@"MKLFXCLoadStatusController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadStatus:)
                                                 name:MKLFXCReceiveLoadChangeNoteStatusNotification
                                               object:nil];
    [self readDataFromDevice];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_ConfigLoadChangeStatus:self.dataModel.stopIsOn
                                          accessIsOn:self.dataModel.startIsOn
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

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKTextSwitchCell *cell = [MKTextSwitchCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - mk_textSwitchCellDelegate
/// 开关状态发生改变了
/// @param isOn 当前开关状态
/// @param index 当前cell所在的index
- (void)mk_textSwitchCellStatusChanged:(BOOL)isOn index:(NSInteger)index {
    MKTextSwitchCellModel *cellModel = self.dataList[index];
    cellModel.isOn = isOn;
    if (index == 0) {
        self.dataModel.startIsOn = isOn;
        return;
    }
    if (index == 1) {
        self.dataModel.stopIsOn = isOn;
        return;
    }
}

#pragma mark - note
- (void)receiveLoadStatus:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1117) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    self.dataModel.startIsOn = ([userInfo[@"data"][@"access_notice"] integerValue] == 1);
    self.dataModel.stopIsOn = ([userInfo[@"data"][@"remove_notice"] integerValue] == 1);
    MKTextSwitchCellModel *cellModel1 = self.dataList[0];
    cellModel1.isOn = self.dataModel.startIsOn;
    
    MKTextSwitchCellModel *cellModel2 = self.dataList[1];
    cellModel2.isOn = self.dataModel.stopIsOn;
    
    [self.tableView reloadData];
}

#pragma mark - interface
- (void)readDataFromDevice {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_readLoadChangeStatusWithDeviceID:self.deviceModel.deviceID
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
    MKTextSwitchCellModel *cellModel1 = [[MKTextSwitchCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Load Start Work Notification";
    [self.dataList addObject:cellModel1];
    
    MKTextSwitchCellModel *cellModel2 = [[MKTextSwitchCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Load Stop Work Notification";
    [self.dataList addObject:cellModel2];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Load Status Notification";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCLoadStatusController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
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
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKLFXCLoadStatusModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXCLoadStatusModel alloc] init];
    }
    return _dataModel;
}

@end
