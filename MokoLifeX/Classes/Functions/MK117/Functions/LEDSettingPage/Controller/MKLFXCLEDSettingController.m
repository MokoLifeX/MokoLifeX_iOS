//
//  MKLFXCLEDSettingController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCLEDSettingController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKSettingTextCell.h"
#import "MKTextSwitchCell.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCDeviceMQTTNotifications.h"

#import "MKLFXCColorSettingController.h"

@interface MKLFXCLEDSettingController ()<UITableViewDelegate,
UITableViewDataSource,
mk_textSwitchCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@end

@implementation MKLFXCLEDSettingController

- (void)dealloc {
    NSLog(@"MKLFXCLEDSettingController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [self readDataFromServer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveRCLEDDatas:)
                                                 name:MKLFXCReceiveRCLEDStatusNotification
                                               object:nil];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self confirmButtonPressed];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        //
        MKLFXCColorSettingController *vc = [[MKLFXCColorSettingController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
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
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        return cell;
    }
    MKTextSwitchCell *cell = [MKTextSwitchCell initCellWithTableView:tableView];
    cell.dataModel = self.section1List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - mk_textSwitchCellDelegate
/// 开关状态发生改变了
/// @param isOn 当前开关状态
/// @param index 当前cell所在的index
- (void)mk_textSwitchCellStatusChanged:(BOOL)isOn index:(NSInteger)index {
    MKTextSwitchCellModel *cellModel = self.section1List[index];
    cellModel.isOn = isOn;
}

#pragma mark - note
- (void)receiveRCLEDDatas:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1119) {
        return;
    }
    [[MKHudManager share] hide];
    [self cancelTimer];
    
    MKTextSwitchCellModel *cellModel1 = self.section1List[0];
    cellModel1.isOn = ([userInfo[@"data"][@"network_led"] integerValue] == 1);
    MKTextSwitchCellModel *cellModel2 = self.section1List[1];
    cellModel2.isOn = ([userInfo[@"data"][@"power_led"] integerValue] == 1);
    [self.tableView reloadData];
}

#pragma mark - event method
- (void)confirmButtonPressed {
    [[MKHudManager share] showHUDWithTitle:@"Config..." inView:self.view isPenetration:NO];
    MKTextSwitchCellModel *cellModel1 = self.section1List[0];
    MKTextSwitchCellModel *cellModel2 = self.section1List[1];
    [MKLFXCMQTTInterface lfxc_configRCLedStatus:cellModel2.isOn
                                    networkIsOn:cellModel1.isOn
                                       deviceID:self.deviceModel.deviceID
                                          topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        [[MKHudManager share] hide];
        [self.view showCentralToast:@"Success"];
    }
                                    failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - interface
- (void)readDataFromServer {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_readRCLedStatusWithDeviceID:self.deviceModel.deviceID
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
    [self loadSection0Datas];
    [self loadSection1Datas];
    
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKSettingTextCellModel *cellModel = [[MKSettingTextCellModel alloc] init];
    cellModel.leftMsg = @"Power Indicator Color";
    [self.section0List addObject:cellModel];
}

- (void)loadSection1Datas {
    MKTextSwitchCellModel *cellModel1 = [[MKTextSwitchCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Network Indicator Status";
    [self.section1List addObject:cellModel1];
    
    MKTextSwitchCellModel *cellModel2 = [[MKTextSwitchCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Power Indicator Status";
    [self.section1List addObject:cellModel2];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"LED Settings";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCLEDSettingController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
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

@end
