//
//  MKEnergyMonthlyTableView.m
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKEnergyMonthlyTableView.h"
#import "MKEnergyTableHeaderView.h"
#import "MKEnergyValueCell.h"
#import "MKEnergyValueCellModel.h"

@interface MKEnergyMonthlyTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *monthlyTableView;

@property (nonatomic, strong)MKEnergyTableHeaderView *monthlyHeader;

@property (nonatomic, strong)MKEnergyTableHeaderViewModel *monthlyHeaderModel;

@property (nonatomic, strong)NSMutableArray *monthlyList;

@property (nonatomic, assign)CGFloat pulseConstant;

@end

@implementation MKEnergyMonthlyTableView

- (void)dealloc {
    NSLog(@"receiveCurrentEnergyNotification销毁");
    
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.monthlyTableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.monthlyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.monthlyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKEnergyValueCell *cell = [MKEnergyValueCell initCellWithTableView:tableView];
    cell.dataModel = self.monthlyList[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)receiveCurrentEnergyNotification:(NSNotification *)note {
    NSString *currentDate = [NSString stringWithFormat:@"%@-%@-%@",note.userInfo[@"date"][@"year"],note.userInfo[@"date"][@"month"],note.userInfo[@"date"][@"day"]];
    if (self.monthlyList.count == 0) {
        //没有数据直接添加
        MKEnergyValueCellModel *newModel = [[MKEnergyValueCellModel alloc] init];
        newModel.timeValue = [NSString stringWithFormat:@"%@-%@",note.userInfo[@"date"][@"month"],note.userInfo[@"date"][@"day"]];
        newModel.dateValue = currentDate;
        newModel.energyValue = note.userInfo[@"currentDayValue"];
        [self.monthlyList addObject:newModel];
    }else {
        BOOL contain = NO;
        for (NSInteger i = 0; i < self.monthlyList.count; i ++) {
            MKEnergyValueCellModel *model = self.monthlyList[i];
            if ([currentDate isEqualToString:model.dateValue]) {
                //存在就替换
                model.energyValue = note.userInfo[@"currentDayValue"];
                contain = YES;
                break;
            }
        }
        if (!contain) {
            //不存在就插入
            MKEnergyValueCellModel *newModel = [[MKEnergyValueCellModel alloc] init];
            newModel.timeValue = [NSString stringWithFormat:@"%@-%@",note.userInfo[@"date"][@"month"],note.userInfo[@"date"][@"day"]];
            newModel.dateValue = currentDate;
            newModel.energyValue = note.userInfo[@"currentDayValue"];
            [self.monthlyList insertObject:newModel atIndex:0];
        }
    }
    
    [self.monthlyTableView reloadData];
    [self reloadHeaderDateInfoWithEnergy:[note.userInfo[@"monthlyValue"] floatValue]];
}

#pragma mark - public method
- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant {
    self.pulseConstant = [pulseConstant floatValue];
    if (self.pulseConstant == 0 || energyList.count == 0) {
        return;
    }
    [self.monthlyList removeAllObjects];
    NSUInteger totalValue = 0;
    for (NSInteger i = energyList.count - 1; i >= 0; i --) {
        NSDictionary *dic = energyList[i];
        MKEnergyValueCellModel *model = [[MKEnergyValueCellModel alloc] init];
        NSString *date = dic[@"date"];
        NSArray *dateList = [date componentsSeparatedByString:@"-"];
        model.timeValue = [NSString stringWithFormat:@"%@-%@",dateList[1],dateList[2]];
        model.dateValue = date;
        model.energyValue = dic[@"rotationsNumber"];
        totalValue += [dic[@"rotationsNumber"] integerValue];
        [self.monthlyList addObject:model];
    }
    [self.monthlyTableView reloadData];
    [self reloadHeaderDateInfoWithEnergy:(totalValue * 1.f)];
}

- (void)resetAllDatas {
    [self.monthlyList removeAllObjects];
    [self.monthlyTableView reloadData];
    self.monthlyHeaderModel.energyValue = @"0.0";
    self.monthlyHeaderModel.dateMsg = [NSString stringWithFormat:@"%@ to %@",@"00-00-00",@"00-00-00"];
    [self.monthlyHeader setViewModel:self.monthlyHeaderModel];
}

#pragma mark - private method
- (void)reloadHeaderDateInfoWithEnergy:(float)energy {
    self.monthlyHeaderModel.energyValue = [NSString stringWithFormat:@"%.2f",energy / self.pulseConstant];
    if (self.monthlyList.count == 0) {
        return;
    }
    MKEnergyValueCellModel *startModel = self.monthlyList.firstObject;
    MKEnergyValueCellModel *endModel = self.monthlyList.lastObject;
    self.monthlyHeaderModel.dateMsg = [NSString stringWithFormat:@"%@ to %@",endModel.dateValue,startModel.dateValue];
    [self.monthlyHeader setViewModel:self.monthlyHeaderModel];
}

#pragma mark - getter
- (MKBaseTableView *)monthlyTableView {
    if (!_monthlyTableView) {
        _monthlyTableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _monthlyTableView.backgroundColor = COLOR_WHITE_MACROS;
        _monthlyTableView.delegate = self;
        _monthlyTableView.dataSource = self;
        _monthlyTableView.tableHeaderView = self.monthlyHeader;
    }
    return _monthlyTableView;
}

- (NSMutableArray *)monthlyList {
    if (!_monthlyList) {
        _monthlyList = [NSMutableArray array];
    }
    return _monthlyList;
}

- (MKEnergyTableHeaderView *)monthlyHeader {
    if (!_monthlyHeader) {
        _monthlyHeader = [[MKEnergyTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 230.f)];
        _monthlyHeader.viewModel = self.monthlyHeaderModel;
    }
    return _monthlyHeader;
}

- (MKEnergyTableHeaderViewModel *)monthlyHeaderModel {
    if (!_monthlyHeaderModel) {
        _monthlyHeaderModel = [[MKEnergyTableHeaderViewModel alloc] init];
        _monthlyHeaderModel.energyValue = @"1";
        _monthlyHeaderModel.timeMsg = @"Date";
    }
    return _monthlyHeaderModel;
}

@end
