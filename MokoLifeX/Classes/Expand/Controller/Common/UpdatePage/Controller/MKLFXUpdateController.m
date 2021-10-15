//
//  MKLFXUpdateController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXUpdateController.h"

#import "Masonry.h"

#import "MLInputDodger.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"
#import "UITableView+MKAdd.h"

#import "MKHudManager.h"
#import "MKTextFieldCell.h"
#import "MKTextButtonCell.h"
#import "MKCustomUIAdopter.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXUpdateModel.h"

@interface MKLFXUpdateController ()<UITableViewDelegate,
UITableViewDataSource,
MKTextButtonCellDelegate,
MKTextFieldCellDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *section0List;

@property (nonatomic, strong)NSMutableArray *section1List;

@property (nonatomic, strong)MKLFXUpdateModel *dataModel;

@end

@implementation MKLFXUpdateController

- (void)dealloc {
    NSLog(@"MKLFXUpdateController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self loadSubViews];
    [self loadSectionDatas];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
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
        MKTextButtonCell *cell = [MKTextButtonCell initCellWithTableView:tableView];
        cell.dataModel = self.section0List[indexPath.row];
        cell.delegate = self;
        return cell;
    }
    MKTextFieldCell *cell = [MKTextFieldCell initCellWithTableView:tableView];
    cell.dataModel = self.section1List[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - MKTextButtonCellDelegate
/// 右侧按钮点击触发的回调事件
/// @param index 当前cell所在的index
/// @param dataListIndex 点击按钮选中的dataList里面的index
/// @param value dataList[dataListIndex]
- (void)mk_loraTextButtonCellSelected:(NSInteger)index
                        dataListIndex:(NSInteger)dataListIndex
                                value:(NSString *)value {
    if (index == 0) {
        //Type
        MKTextButtonCellModel *cellModel = self.section0List[0];
        cellModel.dataListIndex = dataListIndex;
        self.dataModel.type = dataListIndex;
        return;
    }
}

#pragma mark - MKTextFieldCellDelegate
/// textField内容发送改变时的回调事件
/// @param index 当前cell所在的index
/// @param value 当前textField的值
- (void)mk_deviceTextCellValueChanged:(NSInteger)index textValue:(NSString *)value {
    MKTextFieldCellModel *cellModel = self.section1List[index];
    cellModel.textFieldValue = value;
    if (index == 0) {
        //Host
        self.dataModel.host = value;
        return;
    }
    if (index == 1) {
        //Port
        self.dataModel.port = value;
        return;
    }
    if (index == 2) {
        //Catalogue
        self.dataModel.catalogue = value;
        return;
    }
}

#pragma mark - note
- (void)firmwareUpdateResult:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID]) {
        return;
    }
    [[MKHudManager share] hide];
    self.leftButton.enabled = YES;
    if ([userInfo[@"data"][@"ota_result"] isEqualToString:@"R1"]) {
        //升级成功
        [self.view showCentralToast:@"Update Success!"];
        return;
    }
    //升级失败
    [self.view showCentralToast:@"Update Failed!"];
}

#pragma mark - event method
- (void)startButtonPressed {
    if (!ValidStr(self.dataModel.host)) {
        [self.view showCentralToast:@"Host error"];
        return;
    }
    if (!ValidStr(self.dataModel.port) || [self.dataModel.port integerValue] < 0 || [self.dataModel.port integerValue] > 65535) {
        [self.view showCentralToast:@"Port error"];
        return;
    }
    if (!ValidStr(self.dataModel.catalogue)) {
        [self.view showCentralToast:@"Catalogue error"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Updating..." inView:self.view isPenetration:NO];
    @weakify(self);
    [self.protocol updateFile:self.dataModel.type
                         host:self.dataModel.host
                         port:[self.dataModel.port integerValue]
                    catalogue:self.dataModel.catalogue
                     deviceID:self.deviceModel.deviceID
                        topic:[self.deviceModel currentSubscribedTopic]
                     sucBlock:^{
        @strongify(self);
        //监听升级结果
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(firmwareUpdateResult:)
                                                     name:[self.protocol updateResultNotificationName]
                                                   object:nil];
        self.leftButton.enabled = NO;
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
    MKTextButtonCellModel *cellModel = [[MKTextButtonCellModel alloc] init];
    cellModel.index = 0;
    cellModel.msg = @"Type";
    cellModel.dataList = @[@"Firmware",@"CA certification",@"Client certification",@"Client key"];
    cellModel.dataListIndex = self.dataModel.type;
    [self.section0List addObject:cellModel];
}

- (void)loadSection1Datas {
    MKTextFieldCellModel *cellModel1 = [[MKTextFieldCellModel alloc] init];
    cellModel1.index = 0;
    cellModel1.msg = @"Host";
    cellModel1.textFieldType = mk_normal;
    cellModel1.textPlaceholder = @"1-64 Characters";
    cellModel1.textFieldValue = self.dataModel.host;
    cellModel1.maxLength = 64;
    [self.section1List addObject:cellModel1];
    
    MKTextFieldCellModel *cellModel2 = [[MKTextFieldCellModel alloc] init];
    cellModel2.index = 1;
    cellModel2.msg = @"Port";
    cellModel2.textPlaceholder = @"0-65535";
    cellModel2.textFieldType = mk_realNumberOnly;
    cellModel2.maxLength = 5;
    cellModel2.textFieldValue = self.dataModel.port;
    [self.section1List addObject:cellModel2];
    
    MKTextFieldCellModel *cellModel3 = [[MKTextFieldCellModel alloc] init];
    cellModel3.index = 2;
    cellModel3.msg = @"Catalogue";
    cellModel3.textFieldType = mk_normal;
    cellModel3.textPlaceholder = @"1-100 Characters";
    cellModel3.textFieldValue = self.dataModel.catalogue;
    cellModel3.maxLength = 100;
    [self.section1List addObject:cellModel3];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Check Update";
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

- (MKLFXUpdateModel *)dataModel {
    if (!_dataModel) {
        _dataModel = [[MKLFXUpdateModel alloc] init];
    }
    return _dataModel;
}

- (UIView *)footView{
    CGFloat viewHeight = 180.f;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, viewHeight)];
    footView.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    UIButton *startButton = [MKCustomUIAdopter customButtonWithTitle:@"Start Update"
                                                              target:self
                                                              action:@selector(startButtonPressed)];
    startButton.frame = CGRectMake(55.f, viewHeight - 45.f, kViewWidth - 2 * 55, 45.f);
    
    [footView addSubview:startButton];
    
    return footView;
}

@end
