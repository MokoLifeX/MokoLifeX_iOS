//
//  MKLFXBMoreController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/2.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBMoreController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKNormalTextCell.h"
#import "MKCustomUIAdopter.h"
#import "MKAlertController.h"

#import "MKLFXDeviceListDatabaseManager.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXUpdateController.h"
#import "MKLFXDeviceInfoController.h"
#import "MKLFXPowerOnStatusController.h"

#import "MKLFXBMQTTInterface.h"
#import "MKLFXBMQTTManager.h"

#import "MKLFXBMorePageProtocolModel.h"

@interface MKLFXBMoreController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)UITextField *localNameField;

@property (nonatomic, copy)NSString *localNameAsciiStr;

@end

@implementation MKLFXBMoreController

- (void)dealloc {
    NSLog(@"MKLFXBMoreController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        //修改名称
        [self modifyLocalName];
        return;
    }
    if (indexPath.row == 1) {
        //设备信息
        MKLFXDeviceInfoController *vc = [[MKLFXDeviceInfoController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.protocol = [[MKLFXBDeviceInfoDataModel alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 2) {
        //升级
        MKLFXUpdateController *vc = [[MKLFXUpdateController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.protocol = [[MKLFXBUpdateDataModel alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 3) {
        //修改设备默认上电状态
        MKLFXPowerOnStatusController *vc = [[MKLFXPowerOnStatusController alloc] init];
        vc.deviceModel = self.deviceModel;
        vc.protocol = [[MKLFXBPowerOnStatusModel alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKNormalTextCell *cell = [MKNormalTextCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
- (void)removeButtonPressed {
    NSString *msg = @"Please confirm again whether to remove the device.";
    MKAlertController *alertView = [MKAlertController alertControllerWithTitle:@"Remove Device"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
    alertView.notificationName = @"mk_lfxb_dismissAlert";
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
    alertView.notificationName = @"mk_lfxb_dismissAlert";
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

- (void)locaNameTextFieldValueChanged:(UITextField *)textField{
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
    [MKLFXBMQTTInterface lfxb_resetDeviceWithDeviceID:self.deviceModel.deviceID topic:[self.deviceModel currentSubscribedTopic] sucBlock:^{
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
        MKNormalTextCellModel *cellModel1 = self.dataList[0];
        cellModel1.rightMsg = self.localNameAsciiStr;
        [self.tableView mk_reloadRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
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
    MKNormalTextCellModel *cellModel1 = [[MKNormalTextCellModel alloc] init];
    cellModel1.leftMsg = @"Modify device name";
    cellModel1.showRightIcon = YES;
    cellModel1.rightMsg = self.deviceModel.deviceName;
    [self.dataList addObject:cellModel1];
    
    MKNormalTextCellModel *cellModel2 = [[MKNormalTextCellModel alloc] init];
    cellModel2.leftMsg = @"Device information";
    cellModel2.showRightIcon = YES;
    [self.dataList addObject:cellModel2];
    
    MKNormalTextCellModel *cellModel3 = [[MKNormalTextCellModel alloc] init];
    cellModel3.leftMsg = @"Check update";
    cellModel3.showRightIcon = YES;
    [self.dataList addObject:cellModel3];
    
    MKNormalTextCellModel *cellModel4 = [[MKNormalTextCellModel alloc] init];
    cellModel4.leftMsg = @"Modify power on status";
    cellModel4.showRightIcon = YES;
    [self.dataList addObject:cellModel4];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"More";
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
        _tableView.tableFooterView = [self footView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
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
