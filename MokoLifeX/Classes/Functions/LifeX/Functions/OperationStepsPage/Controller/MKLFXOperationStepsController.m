//
//  MKLFXOperationStepsController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/20.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXOperationStepsController.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"

#import "MKCustomUIAdopter.h"

#import "MKLFXOperationStepsCell.h"

@interface MKLFXOperationStepsController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)UIButton *indicatorButton;

@end

@implementation MKLFXOperationStepsController

- (void)dealloc {
    NSLog(@"MKLFXOperationStepsController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadSectionDatas];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 230.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXOperationStepsCell *cell = [MKLFXOperationStepsCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
- (void)indicatorButtonPressed {
    [self leftButtonMethod];
    if (self.indicatorButtonPressedBlock) {
        self.indicatorButtonPressedBlock();
    }
}

#pragma mark - loadSectionDatas
- (void)loadSectionDatas {
    MKLFXOperationStepsCellModel *cellModel1 = [[MKLFXOperationStepsCellModel alloc] init];
    cellModel1.titleMsg = @"Step 1";
    cellModel1.noteMsg = @"Plug the device in power";
    cellModel1.leftIconName = @"lfx_notBlinkAmberStep1_leftIcon.png";
    cellModel1.rightIconName = @"lfx_notBlinkAmberStep1_rightIcon";
    [self.dataList addObject:cellModel1];
    
    MKLFXOperationStepsCellModel *cellModel2 = [[MKLFXOperationStepsCellModel alloc] init];
    cellModel2.titleMsg = @"Step 2";
    cellModel2.noteMsg = @"Hold the button for 10s until the LED blink amber";
    cellModel2.leftIconName = @"lfx_notBlinkAmberStep2_leftIcon.png";
    cellModel2.rightIconName = @"lfx_notBlinkAmberStep2_rightIcon";
    [self.dataList addObject:cellModel2];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Operation Steps";
    [self.view addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
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
        _tableView.backgroundColor = RGBCOLOR(243, 243, 243);
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self footerView];
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (UIButton *)indicatorButton {
    if (!_indicatorButton) {
        _indicatorButton = [MKCustomUIAdopter customButtonWithTitle:@"Indicator blink amber light"
                                                             target:self
                                                             action:@selector(indicatorButtonPressed)];
        _indicatorButton.titleLabel.font = MKFont(16.f);
    }
    return _indicatorButton;
}

- (UIView *)footerView {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 60.f)];
    footerView.backgroundColor = RGBCOLOR(243, 243, 243);
    
    [footerView addSubview:self.indicatorButton];
    [self.indicatorButton setFrame:CGRectMake(30.f, 20.f, kViewWidth - 2 * 30.f, 40.f)];
    
    return footerView;
}

@end
