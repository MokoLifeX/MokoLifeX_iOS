//
//  MKEnergyController.m
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/11.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKEnergyController.h"

#import "MKEnergyDailyTableView.h"
#import "MKEnergyMonthlyTableView.h"

#import "MKDeviceInfoController.h"

@interface MKEnergyController ()

@property (nonatomic, strong)UIView *segment;

@property (nonatomic, strong)UIButton *dailyButton;

@property (nonatomic, strong)UIButton *monthlyButton;

@property (nonatomic, assign)NSInteger selectedIndex;

@property (nonatomic, strong)MKEnergyMonthlyTableView *monthTable;

@property (nonatomic, strong)MKEnergyDailyTableView *dailyTable;

@end

@implementation MKEnergyController

- (void)dealloc {
    NSLog(@"MKEnergyController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self readEnergyDatas];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resetAccumulatedEnergy)
                                                 name:@"resetAccumulatedEnergyNotification"
                                               object:nil];
}

#pragma mark - super method
- (void)leftButtonMethod {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MKPopToRootViewControllerNotification" object:nil];
}

- (void)rightButtonMethod {
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - event emthod
- (void)dailyButtonPressed {
    if (self.selectedIndex == 0) {
        return;
    }
    self.selectedIndex = 0;
    [self reloadSubViews];
}

- (void)monthlyButtonPressed {
    if (self.selectedIndex == 1) {
        return;
    }
    self.selectedIndex = 1;
    [self reloadSubViews];
}

#pragma mark - note
- (void)resetAccumulatedEnergy {
    //接收到了用户重置电能操作，把所有列表数据清0
    [self.dailyTable resetAllDatas];
    [self.monthTable resetAllDatas];
}

#pragma mark - read data
- (void)readEnergyDatas {
//    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
//    WS(weakSelf);
//    [self.dataModel startReadEnergyDatasWithScuBlock:^(NSArray * _Nonnull dailyList, NSArray * _Nonnull monthlyList, NSString * _Nonnull pulseConstant) {
//        [[MKHudManager share] hide];
//        __strong typeof(self) sself = weakSelf;
//        [sself.dailyTable updateEnergyDatas:dailyList pulseConstant:pulseConstant];
//        [sself.monthTable updateEnergyDatas:monthlyList pulseConstant:pulseConstant];
//    } failedBlock:^(NSError * _Nonnull error) {
//        [[MKHudManager share] hide];
//        __strong typeof(self) sself = weakSelf;
//        [sself.view showCentralToast:error.userInfo[@"errorInfo"]];
//    }];
}

#pragma mark - private method
- (void)reloadSubViews {
    UIColor *dailyTitleColor = (self.selectedIndex == 0 ? COLOR_WHITE_MACROS : UIColorFromRGB(0x0188cc));
    UIColor *monthlyTitleColor = (self.selectedIndex == 1 ? COLOR_WHITE_MACROS : UIColorFromRGB(0x0188cc));
    UIColor *dailyBackColor = (self.selectedIndex == 0 ? UIColorFromRGB(0x0188cc) : COLOR_WHITE_MACROS);
    UIColor *monthlyBackColor = (self.selectedIndex == 1 ? UIColorFromRGB(0x0188cc) : COLOR_WHITE_MACROS);
    [self.dailyButton setTitleColor:dailyTitleColor forState:UIControlStateNormal];
    [self.dailyButton setBackgroundColor:dailyBackColor];
    [self.monthlyButton setTitleColor:monthlyTitleColor forState:UIControlStateNormal];
    [self.monthlyButton setBackgroundColor:monthlyBackColor];
    self.dailyTable.hidden = !(self.selectedIndex == 0);
    self.monthTable.hidden = !(self.selectedIndex == 1);
}

#pragma mark - UI
- (void)loadSubViews {
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    [self.rightButton setImage:LOADIMAGE(@"detailIcon", @"png") forState:UIControlStateNormal];
    self.view.backgroundColor = COLOR_WHITE_MACROS;
    [self.view addSubview:self.segment];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(240);
        make.top.mas_equalTo(defaultTopInset + 10.f);
        make.height.mas_equalTo(32.f);
    }];
    [self.segment addSubview:self.dailyButton];
    [self.dailyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(self.segment.mas_centerX);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.segment addSubview:self.monthlyButton];
    [self.monthlyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(self.segment.mas_centerX);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.view addSubview:self.monthTable];
    [self.view addSubview:self.dailyTable];
    [self.monthTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.segment.mas_bottom);
        make.bottom.mas_equalTo(-VirtualHomeHeight - 49.f);
    }];
    [self.dailyTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.monthTable);
    }];
}

#pragma mark - getter
- (UIView *)segment {
    if (!_segment) {
        _segment = [[UIView alloc] init];
        _segment.layer.masksToBounds = YES;
        _segment.layer.borderColor = UIColorFromRGB(0x0188cc).CGColor;
        _segment.layer.borderWidth = 0.5f;
        _segment.layer.cornerRadius = 16.f;
    }
    return _segment;
}

- (UIButton *)dailyButton {
    if (!_dailyButton) {
        _dailyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dailyButton.backgroundColor = UIColorFromRGB(0x0188cc);
        _dailyButton.titleLabel.font = MKFont(14.f);
        [_dailyButton setTitle:@"Daily" forState:UIControlStateNormal];
        [_dailyButton setTitleColor:COLOR_WHITE_MACROS forState:UIControlStateNormal];
        [_dailyButton addTarget:self
                         action:@selector(dailyButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _dailyButton;
}

- (MKEnergyDailyTableView *)dailyTable {
    if (!_dailyTable) {
        _dailyTable = [[MKEnergyDailyTableView alloc] init];
    }
    return _dailyTable;
}

- (UIButton *)monthlyButton {
    if (!_monthlyButton) {
        _monthlyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _monthlyButton.backgroundColor = COLOR_WHITE_MACROS;
        _monthlyButton.titleLabel.font = MKFont(14.f);
        [_monthlyButton setTitle:@"Monthly" forState:UIControlStateNormal];
        [_monthlyButton setTitleColor:UIColorFromRGB(0x0188cc) forState:UIControlStateNormal];
        [_monthlyButton addTarget:self
                           action:@selector(monthlyButtonPressed)
                 forControlEvents:UIControlEventTouchUpInside];
    }
    return _monthlyButton;
}

- (MKEnergyMonthlyTableView *)monthTable {
    if (!_monthTable) {
        _monthTable = [[MKEnergyMonthlyTableView alloc] init];
    }
    return _monthTable;
}

@end
