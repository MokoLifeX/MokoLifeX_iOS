//
//  MKLFXCSettingsController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSettingsController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKSettingTextCell.h"
#import "MKTableSectionLineHeader.h"
#import "MKCustomUIAdopter.h"
#import "MKAlertController.h"

#import "MKLFXDeviceListDatabaseManager.h"

#import "MKLFXUpdateController.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTInterface.h"
#import "MKLFXCMQTTManager.h"

#import "MKLFXCUpdateDataModel.h"

#import "MKLFXCPowerOnStatusController.h"
#import "MKLFXCLEDSettingController.h"
#import "MKLFXCDeviceInfoController.h"
#import "MKLFXCStatusReportController.h"
#import "MKLFXCPowerReportController.h"
#import "MKLFXCEnergyReportController.h"
#import "MKLFXCConnectionController.h"
#import "MKLFXCLoadStatusController.h"
#import "MKLFXCProtectionSettingController.h"
#import "MKLFXCMQTTSettingForDeviceController.h"
#import "MKLFXCSystemTimeController.h"
#import "MKLFXCDModifyServerController.h"

@interface MKLFXCSettingsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *section2List;

@property (nonatomic, strong)NSMutableArray *section3List;

@property (nonatomic, strong)NSMutableArray *section4List;

@property (nonatomic, strong)NSMutableArray *headerList;

@property (nonatomic, strong)UITextField *localNameField;

@property (nonatomic, copy)NSString *localNameAsciiStr;

@end

@implementation MKLFXCSettingsController

- (void)dealloc {
    NSLog(@"MKLFXCSettingsController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveDeviceOverProtectionThreshold:)
                                                 name:@"mk_lfxc_deviceOverProtectionThresholdNotification"
                                               object:nil];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self modifyLocalName];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MKTableSectionLineHeader *headerView = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    headerView.headerModel = self.headerList[section];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
#pragma mark - section0
    if (indexPath.section == 0 && indexPath.row == 0) {
        //Power On Default Mode
        MKLFXCPowerOnStatusController *vc = [[MKLFXCPowerOnStatusController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        //LED Setting
        MKLFXCLEDSettingController *vc = [[MKLFXCLEDSettingController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.section == 0 && indexPath.row == 2) {
        //System Time
        MKLFXCSystemTimeController *vc = [[MKLFXCSystemTimeController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
#pragma mark - section1
    if (indexPath.section == 1 && indexPath.row == 0) {
        //Device Status Report Period
        MKLFXCStatusReportController *vc = [[MKLFXCStatusReportController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        //Power Report Period
        MKLFXCPowerReportController *vc = [[MKLFXCPowerReportController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        //Energy Report Parameters
        MKLFXCEnergyReportController *vc = [[MKLFXCEnergyReportController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
#pragma mark - section2
    if (indexPath.section == 2 && indexPath.row == 0) {
        //Connection Timeout  Setting
        MKLFXCConnectionController *vc = [[MKLFXCConnectionController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.section ==2 && indexPath.row == 1) {
        //Protection Setting
        MKLFXCProtectionSettingController *vc = [[MKLFXCProtectionSettingController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (indexPath.section == 2 && indexPath.row == 2) {
        //Load Status Notification
        MKLFXCLoadStatusController *vc = [[MKLFXCLoadStatusController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
#pragma mark - section3
    if (indexPath.section == 3) {
        if ([self.deviceModel.deviceType integerValue] == 5 && indexPath.row == 0) {
            //MK117D的Modify MQTT settings页面
            MKLFXCDModifyServerController *vc = [[MKLFXCDModifyServerController alloc] init];
            vc.deviceModel = self.deviceModel;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        //OTA
        MKLFXUpdateController *vc = [[MKLFXUpdateController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.protocol = [[MKLFXCUpdateDataModel alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
#pragma mark - section4
    if (indexPath.section == 4 && indexPath.row == 0) {
        //Device Information
        MKLFXCDeviceInfoController *vc = [[MKLFXCDeviceInfoController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.section == 4 && indexPath.row == 1) {
        //Settings for Device
        MKLFXCMQTTSettingForDeviceController *vc = [[MKLFXCMQTTSettingForDeviceController alloc] init];
        vc.deviceModel = self.deviceModel;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerList.count;
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
    if (section == 3) {
        return self.section3List.count;
    }
    return self.section4List.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        return cell;
    }
    if (indexPath.section == 1) {
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section1List[indexPath.row];
        return cell;
    }
    if (indexPath.section == 2) {
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section2List[indexPath.row];
        return cell;
    }
    if (indexPath.section == 3) {
        MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:tableView];
        cell.dataModel = self.section3List[indexPath.row];
        return cell;
    }
    MKSettingTextCell *cell = [MKSettingTextCell initCellWithTableView:tableView];
    cell.dataModel = self.section4List[indexPath.row];
    return cell;
}

#pragma mark - notes
- (void)receiveDeviceOverProtectionThreshold:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || ![userInfo[@"deviceID"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    //当前设备处于过载/过流/过压状态
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:NSClassFromString(@"MKLFXCSwitchStateController")]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

#pragma mark - event method
- (void)removeButtonPressed {
    NSString *msg = @"Please confirm again whether to remove the device.";
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Remove Device"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    alertView.notificationName = @"mk_lfxc_dismissAlert";
    @weakify(self);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self deleteDeviceFormLocal];
    }];
    [alertView addAction:moreAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)resetButtonPressed {
    NSString *msg = @"After reset,the device will be removed from the device list,and relevant data will be totally cleared.";
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Reset Device"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    alertView.notificationName = @"mk_lfxc_dismissAlert";
    @weakify(self);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertView addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self resetDevice];
    }];
    [alertView addAction:moreAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)locaNameTextFieldValueChanged:(UITextField *)textField {
    NSString *inputValue = textField.text;
    if (!ValidStr(inputValue)) {
        textField.text = @"";
        self.localNameAsciiStr = @"";
        return;
    }
    NSInteger strLen = inputValue.length;
    NSInteger dataLen = [inputValue dataUsingEncoding:NSUTF8StringEncoding].length;
    
    NSString *currentStr = self.localNameAsciiStr;
    if (dataLen == strLen) {
        //当前输入是ascii字符
        currentStr = inputValue;
    }
    if (currentStr.length > 20) {
        textField.text = [currentStr substringToIndex:20];
        self.localNameAsciiStr = [currentStr substringToIndex:20];
    }else {
        textField.text = currentStr;
        self.localNameAsciiStr = currentStr;
    }
}

#pragma mark - 移除设备
- (void)deleteDeviceFormLocal {
    [[MKHudManager share] showHUDWithTitle:@"Delete..." inView:self.view isPenetration:NO];
    [MKLFXDeviceListDatabaseManager deleteDeviceWithMacAddress:self.deviceModel.macAddress
                                                      sucBlock:^{
        [[MKHudManager share] hide];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfx_deleteDeviceNotification"
                                                            object:nil
                                                          userInfo:@{
            @"macAddress":SafeStr(self.deviceModel.macAddress),
        }];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
                                                   failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 恢复出厂设置
- (void)resetDevice {
    [[MKHudManager share] showHUDWithTitle:@"Waiting..." inView:self.view isPenetration:NO];
    [MKLFXCMQTTInterface lfxc_resetDeviceWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
        [[MKHudManager share] hide];
        [self deleteDeviceFormLocal];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - 修改名称
- (void)modifyLocalName {
    @weakify(self);
    NSString *msg = @"Note:The local name should be 1-20 characters.";
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Edit Local Name"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    alertView.notificationName = @"mk_lfxb_dismissAlert";
    [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        @strongify(self);
        self.localNameField = nil;
        self.localNameField = textField;
        self.localNameField.text = self.deviceModel.deviceName;
        self.localNameAsciiStr = self.deviceModel.deviceName;
        [self.localNameField setPlaceholder:@"1-20 characters"];
        [self.localNameField addTarget:self
                                action:@selector(locaNameTextFieldValueChanged:)
                      forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:cancelAction];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        [self saveDeviceLocalName];
    }];
    [alertView addAction:moreAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
}

- (void)saveDeviceLocalName {
    if (!ValidStr(self.localNameAsciiStr) || self.localNameAsciiStr.length > 20) {
        [self.view showCentralToast:@"The local name should be 1-20 characters."];
        return;
    }
    MKLFXDeviceModel *deviceModel = [[MKLFXDeviceModel alloc] init];
    deviceModel.deviceID = self.deviceModel.deviceID;
    deviceModel.clientID = self.deviceModel.clientID;
    deviceModel.deviceName = self.localNameAsciiStr;
    deviceModel.subscribedTopic = self.deviceModel.subscribedTopic;
    deviceModel.publishedTopic = self.deviceModel.publishedTopic;
    deviceModel.macAddress = self.deviceModel.macAddress;
    deviceModel.deviceType = self.deviceModel.deviceType;
    [[MKHudManager share] showHUDWithTitle:@"Save..." inView:self.view isPenetration:NO];
    [MKLFXDeviceListDatabaseManager insertDeviceList:@[deviceModel] sucBlock:^{
        [[MKHudManager share] hide];
        self.deviceModel.deviceName = self.localNameAsciiStr;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfx_deviceNameChangedNotification"
                                                            object:nil
                                                          userInfo:@{
                                                              @"macAddress":self.deviceModel.macAddress,
                                                              @"deviceName":self.localNameAsciiStr
                                                          }];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    [self loadSection2Datas];
    [self loadSection3Datas];
    [self loadSection4Datas];
    
    for (NSInteger i = 0; i < 5; i ++) {
        MKTableSectionLineHeaderModel *headerModel = [[MKTableSectionLineHeaderModel alloc] init];
        [self.headerList addObject:headerModel];
    }
    
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKSettingTextCellModel *cellModel1 = [[MKSettingTextCellModel alloc] init];
    cellModel1.leftMsg = @"Power On Default Mode";
    [self.section0List addObject:cellModel1];
    
    MKSettingTextCellModel *cellModel2 = [[MKSettingTextCellModel alloc] init];
    cellModel2.leftMsg = @"LED Setting";
    [self.section0List addObject:cellModel2];
    
    MKSettingTextCellModel *cellModel3 = [[MKSettingTextCellModel alloc] init];
    cellModel3.leftMsg = @"System Time";
    [self.section0List addObject:cellModel3];
}

- (void)loadSection1Datas {
    MKSettingTextCellModel *cellModel1 = [[MKSettingTextCellModel alloc] init];
    cellModel1.leftMsg = @"Device Status Report Period";
    [self.section1List addObject:cellModel1];
    
    MKSettingTextCellModel *cellModel2 = [[MKSettingTextCellModel alloc] init];
    cellModel2.leftMsg = @"Power Report Period";
    [self.section1List addObject:cellModel2];
    
    MKSettingTextCellModel *cellModel3 = [[MKSettingTextCellModel alloc] init];
    cellModel3.leftMsg = @"Energy Report Parameters";
    [self.section1List addObject:cellModel3];
}

- (void)loadSection2Datas {
    MKSettingTextCellModel *cellModel1 = [[MKSettingTextCellModel alloc] init];
    cellModel1.leftMsg = @"Connection Timeout Setting";
    [self.section2List addObject:cellModel1];
    
    MKSettingTextCellModel *cellModel2 = [[MKSettingTextCellModel alloc] init];
    cellModel2.leftMsg = @"Protection Setting";
    [self.section2List addObject:cellModel2];
    
    MKSettingTextCellModel *cellModel3 = [[MKSettingTextCellModel alloc] init];
    cellModel3.leftMsg = @"Load Status Notification";
    [self.section2List addObject:cellModel3];
}

- (void)loadSection3Datas {
    if ([self.deviceModel.deviceType integerValue] == 5) {
        //MK117D
        MKSettingTextCellModel *cellModel1 = [[MKSettingTextCellModel alloc] init];
        cellModel1.leftMsg = @"Modify MQTT settings";
        [self.section3List addObject:cellModel1];
    }
    MKSettingTextCellModel *cellModel2 = [[MKSettingTextCellModel alloc] init];
    cellModel2.leftMsg = @"OTA";
    [self.section3List addObject:cellModel2];
}

- (void)loadSection4Datas {
    MKSettingTextCellModel *cellModel1 = [[MKSettingTextCellModel alloc] init];
    cellModel1.leftMsg = @"Device Information";
    [self.section4List addObject:cellModel1];
    
    MKSettingTextCellModel *cellModel2 = [[MKSettingTextCellModel alloc] init];
    cellModel2.leftMsg = @"Settings for Device";
    [self.section4List addObject:cellModel2];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Settings";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCSettingsController", @"lfx_editIcon.png") forState:UIControlStateNormal];
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
        _tableView.tableFooterView = [self footView];
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

- (NSMutableArray *)section3List {
    if (!_section3List) {
        _section3List = [NSMutableArray array];
    }
    return _section3List;
}

- (NSMutableArray *)section4List {
    if (!_section4List) {
        _section4List = [NSMutableArray array];
    }
    return _section4List;
}

- (NSMutableArray *)headerList {
    if (!_headerList) {
        _headerList = [NSMutableArray array];
    }
    return _headerList;
}

- (UIView *)footView{
    CGFloat viewHeight = 180.f;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, viewHeight)];
    footView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *removeButton = [MKCustomUIAdopter customButtonWithTitle:@"Remove Device"
                                                               target:self
                                                               action:@selector(removeButtonPressed)];
    UIButton *resetButton = [MKCustomUIAdopter customButtonWithTitle:@"Reset"
                                                              target:self
                                                              action:@selector(resetButtonPressed)];
    resetButton.frame = CGRectMake(55.f, viewHeight - 45.f, kViewWidth - 2 * 55, 45.f);
    removeButton.frame = CGRectMake(55.f, viewHeight - 2 * 45.f - 30.f, kViewWidth - 2 * 55, 45.f);
    
    [footView addSubview:removeButton];
    [footView addSubview:resetButton];
    
    return footView;
}

@end
