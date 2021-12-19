//
//  MKLFXCDModifyServerController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/6.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCDModifyServerController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "NSString+MKAdd.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextFieldCell.h"
#import "MKTextButtonCell.h"
#import "MKTextSwitchCell.h"
#import "MKTableSectionLineHeader.h"
#import "MKCustomUIAdopter.h"
#import "MKProgressView.h"

#import "MKLFXDeviceListDatabaseManager.h"

#import "MKLFXCDModifyServerFooterView.h"

#import "MKLFXCDModifyServerModel.h"

#import "MKLFXDeviceModel.h"

@interface MKLFXCDModifyServerController ()<UITableViewDelegate,
UITableViewDataSource,
MKTextFieldCellDelegate,
MKLFXCDModifyServerFooterViewDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)NSMutableArray *sectionHeaderList;

@property (nonatomic, strong)MKLFXCDModifyServerModel *dataModel;

@property (nonatomic, strong)MKLFXCDModifyServerFooterView *sslParamsView;

@property (nonatomic, strong)MKLFXCDModifyServerFooterViewModel *sslParamsModel;

@property (nonatomic, strong)UIView *footerView;

@end

@implementation MKLFXCDModifyServerController

- (void)dealloc {
    NSLog(@"MKLFXCDModifyServerController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //本页面禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.0f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
}

#pragma mark - super method
- (void)rightButtonMethod {
    [self updateMQTTServer];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        MKTextFieldCellModel *cellModel = self.section1List[indexPath.row];
        return [cellModel cellHeightWithContentWidth:kViewWidth];
    }
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MKTableSectionLineHeader *header = [MKTableSectionLineHeader initHeaderViewWithTableView:tableView];
    header.headerModel = self.sectionHeaderList[section];
    return header;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionHeaderList.count;
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
        MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:tableView];
    cell.dataModel = self.section1List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKTextFieldCellDelegate
/// textField内容发送改变时的回调事件
/// @param index 当前cell所在的index
/// @param value 当前textField的值
- (void)mk_deviceTextCellValueChanged:(NSInteger)index textValue:(NSString *)value {
    if (index == 0) {
        //host
        self.dataModel.host = value;
        MKTextFieldCellModel *cellModel = self.section0List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 1) {
        //Port
        self.dataModel.port = value;
        MKTextFieldCellModel *cellModel = self.section0List[1];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 2) {
        //clientID
        self.dataModel.clientID = value;
        MKTextFieldCellModel *cellModel = self.section0List[2];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 3) {
        //Subscribe
        self.dataModel.subscribeTopic = value;
        MKTextFieldCellModel *cellModel = self.section1List[0];
        cellModel.textFieldValue = value;
        return;
    }
    if (index == 4) {
        //Publish
        self.dataModel.publishTopic = value;
        MKTextFieldCellModel *cellModel = self.section1List[1];
        cellModel.textFieldValue = value;
        return;
    }
}

#pragma mark - MKLFXCDModifyServerFooterViewDelegate
/// 用户改变了开关状态
/// @param isOn isOn
/// @param statusID 0:cleanSession   1:ssl
- (void)lfxc_117d_mqtt_modifyMQTT_switchStatusChanged:(BOOL)isOn statusID:(NSInteger)statusID {
    if (statusID == 0) {
        //cleanSession
        self.dataModel.cleanSession = isOn;
        self.sslParamsModel.cleanSession = isOn;
        return;
    }
    if (statusID == 1) {
        //ssl
        self.dataModel.sslIsOn = isOn;
        self.sslParamsModel.sslIsOn = isOn;
        //动态刷新footer
        [self setupSSLViewFrames];
        self.sslParamsView.dataModel = self.sslParamsModel;
        return;
    }
}

/// 输入框内容发生了改变
/// @param text 最新的输入框内容
/// @param textID 0:keepAlive    1:userName     2:password    3:wifiSSID   4:Password  5:sslHost    6:sslPort   7:CA File Path    8:Client Key File   9:Client Cert  File
- (void)lfxc_117d_mqtt_modifyMQTT_textFieldValueChanged:(NSString *)text textID:(NSInteger)textID {
    if (textID == 0) {
        //keepAlive
        self.dataModel.keepAlive = text;
        self.sslParamsModel.keepAlive = text;
        return;
    }
    if (textID == 1) {
        //userName
        self.dataModel.userName = text;
        self.sslParamsModel.userName = text;
        return;
    }
    if (textID == 2) {
        //password
        self.dataModel.password = text;
        self.sslParamsModel.password = text;
        return;
    }
    if (textID == 3) {
        //wifi ssid
        self.dataModel.wifiSSID = text;
        self.sslParamsModel.wifiSSID = text;
        return;
    }
    if (textID == 4) {
        //wifi password
        self.dataModel.wifiPassword = text;
        self.sslParamsModel.wifiPassword = text;
        return;
    }
    if (textID == 5) {
        //sslHost
        self.dataModel.sslHost = text;
        self.sslParamsModel.sslHost = text;
        return;
    }
    if (textID == 6) {
        //sslPort
        self.dataModel.sslPort = text;
        self.sslParamsModel.sslPort = text;
        return;
    }
    if (textID == 7) {
        //CA File Path
        self.dataModel.caFilePath = text;
        self.sslParamsModel.caFilePath = text;
        return;
    }
    if (textID == 8) {
        //Client Key File
        self.dataModel.clientKeyPath = text;
        self.sslParamsModel.clientKeyPath = text;
        return;
    }
    if (textID == 9) {
        //Client Cert
        self.dataModel.clientCertPath = text;
        self.sslParamsModel.clientCertPath = text;
        return;
    }
}

- (void)lfxc_117d_mqtt_modifyMQTT_qosChanged:(NSInteger)qos {
    self.dataModel.qos = qos;
    self.sslParamsModel.qos = qos;
}

/// 用户选择了加密方式
/// @param certificate 0:CA signed server certificate     1:CA certificate     2:Self signed certificates
- (void)lfxc_117d_mqtt_modifyMQTT_certificateChanged:(NSInteger)certificate {
    self.dataModel.certificate = certificate;
    self.sslParamsModel.certificate = certificate;
    //动态刷新footer
    [self setupSSLViewFrames];
    self.sslParamsView.dataModel = self.sslParamsModel;
}

#pragma mark - 入网
/*
 1、先发送更新的服务器信息给设备，设备接收到之后会处理相关逻辑，当设备上报1124的时候表明已经处理完毕。
 2、如果上报1124的通知里面的下载结果成功，则需要发送设备重入网指令给设备
 3、当重入网指令发送成功之后，收到设备上报2127通知，result=1表明切网成功直接跳转到设备列表页面(首页)
 */
- (void)updateMQTTServer {
    [[MKHudManager share] showHUDWithTitle:@"Waiting..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.dataModel updateServerWithDeviceID:self.deviceModel.deviceID
                                  macAddress:self.deviceModel.macAddress
                                  deviceName:self.deviceModel.deviceName
                                       topic:[self.deviceModel currentSubscribedTopic]
                                    sucBlock:^{
        @strongify(self);
        [[MKHudManager share] hide];
        [self updateLocal];
    }
                                 failedBlock:^(NSError * _Nonnull error) {
        @strongify(self);
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)updateLocal {
    
    MKLFXDeviceModel *deviceModel = [[MKLFXDeviceModel alloc] init];
    deviceModel.deviceType = self.deviceModel.deviceType;
    deviceModel.deviceID = self.deviceModel.deviceID;
    deviceModel.deviceName = self.deviceModel.deviceName;
    deviceModel.macAddress = self.deviceModel.macAddress;
    
    deviceModel.clientID = self.dataModel.clientID;
    deviceModel.subscribedTopic = [self.dataModel currentSubscribeTopic];
    deviceModel.publishedTopic = [self.dataModel currentPublishTopic];
    deviceModel.state = MKLFXDeviceModelStateOff;
    
    [MKLFXDeviceListDatabaseManager insertDeviceList:@[deviceModel] sucBlock:^{
        [[MKHudManager share] hide];
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mk_lfx_addNewDeviceSuccessNotification"
                                                            object:nil
                                                          userInfo:@{@"deviceModel":deviceModel}];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    [self loadSection0Datas];
    [self loadSection1Datas];
    
    [self loadSectionHeaderDatas];
    [self loadFooterViewDatas];
    
    [self.tableView reloadData];
}

- (void)loadSection0Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Host";
    cellModel1.textPlaceholder = @"1-64 Characters";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textFieldValue = self.dataModel.host;
    cellModel1.maxLength = 64;
    [self.section0List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Port";
    cellModel2.textPlaceholder = @"0-65535";
    cellModel2.textFieldType = mk_realNumberOnly;
    cellModel2.textFieldValue = self.dataModel.port;
    cellModel2.maxLength = 5;
    [self.section0List addObject:cellModel2];
    
    MKTextFieldCellModel *cellModel3 = [[MKTextFieldCellModel alloc] init];
    cellModel3.index = 2;
    cellModel3.msg = @"Client Id";
    cellModel3.textPlaceholder = @"1-64 Characters";
    cellModel3.textFieldType = mk_normal;
    cellModel3.textFieldValue = self.dataModel.clientID;
    cellModel3.maxLength = 64;
    [self.section0List addObject:cellModel3];
}

- (void)loadSection1Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 3;
    cellModel1.msg = @"Subscribe";
    cellModel1.textPlaceholder = @"1-128 Characters";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textFieldValue = self.dataModel.subscribeTopic;
    cellModel1.maxLength = 128;
    [self.section1List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 4;
    cellModel2.msg = @"Publish";
    cellModel2.textPlaceholder = @"1-128 Characters";
    cellModel2.textFieldType = mk_normal;
    cellModel2.textFieldValue = self.dataModel.publishTopic;
    cellModel2.maxLength = 128;
    cellModel2.noteMsg = @"Note: Input your topics to communicate with the device or set the topics to empty.";
    [self.section1List addObject:cellModel2];
}

- (void)loadSectionHeaderDatas {
    MKTableSectionLineHeaderModel *section0Model = [[MKTableSectionLineHeaderModel alloc] init];
    section0Model.contentColor = RGBCOLOR(242, 242, 242);
    section0Model.text = @"Broker Setting";
    [self.sectionHeaderList addObject:section0Model];
    
    MKTableSectionLineHeaderModel *section0Mode2 = [[MKTableSectionLineHeaderModel alloc] init];
    section0Mode2.contentColor = RGBCOLOR(242, 242, 242);
    section0Mode2.text = @"Topics";
    [self.sectionHeaderList addObject:section0Mode2];
}

- (void)loadFooterViewDatas {
    self.sslParamsModel.cleanSession = self.dataModel.cleanSession;
    self.sslParamsModel.qos = self.dataModel.qos;
    self.sslParamsModel.keepAlive = self.dataModel.keepAlive;
    self.sslParamsModel.userName = self.dataModel.userName;
    self.sslParamsModel.password = self.dataModel.password;
    self.sslParamsModel.sslIsOn = self.dataModel.sslIsOn;
    self.sslParamsModel.certificate = self.dataModel.certificate;
    self.sslParamsModel.caFilePath = self.dataModel.caFilePath;
    self.sslParamsModel.clientKeyPath = self.dataModel.clientKeyPath;
    self.sslParamsModel.clientCertPath = self.dataModel.clientCertPath;
    self.sslParamsModel.sslHost = self.dataModel.sslHost;
    self.sslParamsModel.sslPort = self.dataModel.sslPort;
    
    //动态布局底部footer
    [self setupSSLViewFrames];
    
    self.sslParamsView.dataModel = self.sslParamsModel;
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Modify MQTT settings";
    [self.rightButton setImage:LOADICON(@"MokoLifeX", @"MKLFXCDModifyServerController", @"lfx_saveIcon.png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

- (void)setupSSLViewFrames {
    if (self.sslParamsView.superview) {
        [self.sslParamsView removeFromSuperview];
    }

    CGFloat height = [self.sslParamsView fetchHeightWithSSLStatus:self.dataModel.sslIsOn
                                                      certificate:self.dataModel.certificate];
    
    [self.footerView addSubview:self.sslParamsView];
    self.footerView.frame = CGRectMake(0, 0, kViewWidth, height + 70.f);
    self.sslParamsView.frame = CGRectMake(0, 0, kViewWidth, height);
    self.tableView.tableFooterView = self.footerView;
}

#pragma mark - getter

- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = RGBCOLOR(242, 242, 242);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = self.footerView;
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

- (MKLFXCDModifyServerModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXCDModifyServerModel alloc] init];
    }
    return _dataModel;
}

- (NSMutableArray *)sectionHeaderList {
    if (!_sectionHeaderList) {
        _sectionHeaderList = [NSMutableArray array];
    }
    return _sectionHeaderList;
}

- (MKLFXCDModifyServerFooterView *)sslParamsView {
    if (!_sslParamsView) {
        _sslParamsView = [[MKLFXCDModifyServerFooterView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 380.f)];
        _sslParamsView.delegate = self;
    }
    return _sslParamsView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 450.f)];
        _footerView.backgroundColor = COLOR_WHITE_MACROS;
        [_footerView addSubview:self.sslParamsView];
    }
    return _footerView;
}

- (MKLFXCDModifyServerFooterViewModel *)sslParamsModel {
    if (!_sslParamsModel) {
        _sslParamsModel = [[MKLFXCDModifyServerFooterViewModel alloc] init];
    }
    return _sslParamsModel;
}

@end
