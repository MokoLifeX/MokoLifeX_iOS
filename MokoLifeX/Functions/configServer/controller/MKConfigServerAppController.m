//
//  MKConfigServerAppController.m
//  MokoLifeX
//
//  Created by aa on 2019/7/23.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKConfigServerAppController.h"
#import "MKBaseTableView.h"

#import "MKConfigServerConnectModeCell.h"
#import "MKConfigServerSSLCertCell.h"

#import "MKConfigServerSSLCertModel.h"
#import "MKConfigServerModel.h"
#import "MKConfigServerCellProtocol.h"

#import "MKCertListController.h"

@interface MKConfigServerAppController ()<UITableViewDelegate, UITableViewDataSource, MKConnectModeCellDelegate, MKConfigServerSSLCertCellDelegate,MKCertSelectedDelegate>

/**
 Host---->Connect mode
 */
@property (nonatomic, strong)NSMutableArray *dataList;

/**
 ssl相关cell
 */
@property (nonatomic, strong)NSMutableArray *certDataList;

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)MKConfigServerModel *serverModel;

@property (nonatomic, assign)BOOL needConnect;

@end

@implementation MKConfigServerAppController

- (void)dealloc {
    NSLog(@"MKConfigServerAppController销毁");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.view.shiftHeightAsDodgeViewForMLInputDodger = 50.f;
    [self.view registerAsDodgeViewForMLInputDodgerWithOriginalY:self.view.frame.origin.y];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.needConnect) {
        [[MKMQTTServerDataManager sharedInstance] connectServer];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self.serverModel updateServerDataWithModel:[MKMQTTServerDataManager sharedInstance].configServerModel];
    [self loadCertDatas];
    [self processParams];
    // Do any additional setup after loading the view.
}

#pragma mark - super method
- (void)rightButtonMethod{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Clear All Parameters"
                                                                             message:@"Please confirm whether to clear all parameters"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       
                                                   }];
    WS(weakSelf);
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [MKConfigServerAdopter clearAllConfigCellValuesWithTable:weakSelf.tableView];
                                                    }];
    
    [alertController addAction:cancel];
    [alertController addAction:confirm];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 60.f;
    }
    return 40.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.dataList.count;
    }
    if (section == 1) {
        if (self.serverModel.connectMode == 0) {
            return 0;
        }
        if (self.serverModel.connectMode == 1) {
            return 1;
        }
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return self.dataList[indexPath.row];
    }
    MKConfigServerSSLCertCell *cell = [MKConfigServerSSLCertCell initCellWithTableView:tableView];
    cell.dataModel = self.certDataList[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKConnectModeCellDelegate
- (void)connectModeChanged:(NSInteger)mode {
    self.serverModel.connectMode = mode;
    [self.tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - MKConfigServerSSLCertCellDelegate
- (void)sslCertCellSelectedButtonPressed:(NSInteger)index {
    MKCertListController *vc = [[MKCertListController alloc] init];
    if (index == 0) {
        vc.pageType = mk_caCertSelPage;
    }else {
        vc.pageType = mk_clientP12CertPage;
    }
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MKCertSelectedDelegate
- (void)mk_certSelectedMethod:(mk_certListPageType)certType certName:(NSString *)certName {
    if (certType == mk_caCertSelPage) {
        //CA Cert
        self.serverModel.caFileName = certName;
    }else if (certType == mk_clientKeySelPage) {
        //client key
        self.serverModel.clientKeyName = certName;
    }else if (certType == mk_clientCertSelPage) {
        //client cert
        self.serverModel.clientCertName = certName;
    }else if (certType == mk_clientP12CertPage) {
        self.serverModel.clientP12CertName = certName;
    }
    NSInteger index = (certType == mk_clientP12CertPage) ? 1 : 0;
    MKConfigServerSSLCertModel *certModel = self.certDataList[index];
    certModel.certName = certName;
    [self.tableView reloadRow:index inSection:1 withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - event method

/**
 qos选择器出现的时候需要隐藏键盘
 */
- (void)configCellNeedHiddenKeyboard{
    [MKConfigServerAdopter configCellResignFirstResponderWithTable:self.tableView];
}
- (void)saveButtonPressed{
    MKConfigServerModel *serverModel = [MKConfigServerAdopter currentServerModelWithDataList:self.dataList isApp:YES];
    BOOL paramCheck = [MKConfigServerAdopter checkConfigServerParams:serverModel target:self];
    if (!paramCheck) {
        //存在参数错误
        return;
    }
    if (self.serverModel.connectMode == 2 && !ValidStr(self.serverModel.clientP12CertName)) {
        //双向验证
        [self.view showCentralToast:@"必须选择客户端证书"];
        return;
    }
    //保存参数到本地
    self.serverModel.host = serverModel.host;
    self.serverModel.port = serverModel.port;
    self.serverModel.cleanSession = serverModel.cleanSession;
    self.serverModel.connectMode = serverModel.connectMode;
    self.serverModel.qos = serverModel.qos;
    self.serverModel.keepAlive = serverModel.keepAlive;
    self.serverModel.clientId = serverModel.clientId;
    self.serverModel.userName = serverModel.userName;
    self.serverModel.password = serverModel.password;
    [[MKMQTTServerDataManager sharedInstance] saveServerConfigDataToLocal:self.serverModel];
    self.needConnect = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private method
- (void)processParams {
    //qos选择器出现的时候需要隐藏键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configCellNeedHiddenKeyboard) name:configCellNeedHiddenKeyboardNotification
                                               object:nil];
    [self.dataList addObjectsFromArray:[MKConfigServerAdopter configTopCellWithConfigModel:self.serverModel
                                                                                 tableView:self.tableView isApp:YES]];
    MKConfigServerConnectModeCell *modelCell = [self.dataList lastObject];
    modelCell.delegate = self;
    [self.tableView reloadData];
}

- (void)loadCertDatas {
    MKConfigServerSSLCertModel *caFileModel = [[MKConfigServerSSLCertModel alloc] init];
    caFileModel.msgTitle = @"CA File:";
    caFileModel.index = 0;
    caFileModel.certName = self.serverModel.caFileName;
    [self.certDataList addObject:caFileModel];
    
//    MKConfigServerSSLCertModel *clientKeyModel = [[MKConfigServerSSLCertModel alloc] init];
//    clientKeyModel.msgTitle = @"Client Key:";
//    clientKeyModel.index = 1;
//    clientKeyModel.certName = self.serverModel.clientKeyName;
//    [self.certDataList addObject:clientKeyModel];
    
    MKConfigServerSSLCertModel *clientCertModel = [[MKConfigServerSSLCertModel alloc] init];
    clientCertModel.msgTitle = @"Client Certificate File:";
    clientCertModel.index = 1;
    clientCertModel.certName = self.serverModel.clientP12CertName;
    [self.certDataList addObject:clientCertModel];
}

#pragma mark - UI

- (void)loadSubViews {
    self.titleLabel.text = @"MQTT settings for APP";
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    [self.rightButton setTitle:@"Clear" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(defaultTopInset);
        make.bottom.mas_equalTo(-VirtualHomeHeight);
    }];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = UIColorFromRGB(0xf2f2f2);
        
        _tableView.tableFooterView = [self tableFooter];
        _tableView.tableHeaderView = [self tableHeader];
    }
    return _tableView;
}

- (UIView *)tableHeader{
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20.f)];
    tableHeader.backgroundColor = UIColorFromRGB(0xf2f2f2);
    return tableHeader;
}

- (UIView *)tableFooter{
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 200.f)];
    tableFooter.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *saveButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Save"
                                                                    target:self
                                                                    action:@selector(saveButtonPressed)];
    [tableFooter addSubview:saveButton];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.width.mas_equalTo(kScreenWidth - 2 * 58);
        make.bottom.mas_equalTo(-75.f);
        make.height.mas_equalTo(50.f);
    }];
    return tableFooter;
}

- (MKConfigServerModel *)serverModel{
    if (!_serverModel) {
        _serverModel = [[MKConfigServerModel alloc] init];
    }
    return _serverModel;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)certDataList {
    if (!_certDataList) {
        _certDataList = [NSMutableArray array];
    }
    return _certDataList;
}


@end
