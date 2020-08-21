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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveCurrentEnergyNotification:)
                                                     name:MKMQTTServerReceivedCurrentEnergyNotification
                                                   object:nil];
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
    NSDictionary *userInfo = note.userInfo[@"userInfo"];
    if (!ValidDict(userInfo) || ![userInfo[@"id"] isEqualToString:MKDeviceModelManager.shared.deviceModel.mqttID]) {
        return;
    }
    NSDictionary *energyDic = [self parseCurrentEnergyDatas:userInfo];
    NSString *currentDate = [NSString stringWithFormat:@"%@-%@-%@",energyDic[@"date"][@"year"],energyDic[@"date"][@"month"],energyDic[@"date"][@"day"]];
    if (self.monthlyList.count == 0) {
        //没有数据直接添加
        MKEnergyValueCellModel *newModel = [[MKEnergyValueCellModel alloc] init];
        newModel.timeValue = [NSString stringWithFormat:@"%@-%@",energyDic[@"date"][@"month"],energyDic[@"date"][@"day"]];
        newModel.dateValue = currentDate;
        newModel.energyValue = energyDic[@"currentDayValue"];
        [self.monthlyList addObject:newModel];
    }else {
        BOOL contain = NO;
        for (NSInteger i = 0; i < self.monthlyList.count; i ++) {
            MKEnergyValueCellModel *model = self.monthlyList[i];
            if ([currentDate isEqualToString:model.dateValue]) {
                //存在就替换
                model.energyValue = energyDic[@"currentDayValue"];
                contain = YES;
                break;
            }
        }
        if (!contain) {
            //不存在就插入
            MKEnergyValueCellModel *newModel = [[MKEnergyValueCellModel alloc] init];
            newModel.timeValue = [NSString stringWithFormat:@"%@-%@",energyDic[@"date"][@"month"],energyDic[@"date"][@"day"]];
            newModel.dateValue = currentDate;
            newModel.energyValue = energyDic[@"currentDayValue"];
            [self.monthlyList insertObject:newModel atIndex:0];
        }
    }
    
    [self.monthlyTableView reloadData];
    [self reloadHeaderDateInfoWithEnergy:[energyDic[@"monthlyValue"] floatValue]];
}

#pragma mark - public method
- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant {
    self.pulseConstant = [pulseConstant floatValue];
    if (energyList.count == 0) {
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
    self.monthlyHeaderModel.energyValue = (self.pulseConstant == 0 ? @"0" : [NSString stringWithFormat:@"%.2f",energy / self.pulseConstant]);
    [self.monthlyHeader setViewModel:self.monthlyHeaderModel];
//    if (self.monthlyList.count == 0) {
//        return;
//    }
//    MKEnergyValueCellModel *startModel = self.monthlyList.firstObject;
//    MKEnergyValueCellModel *endModel = self.monthlyList.lastObject;
//    self.monthlyHeaderModel.dateMsg = [NSString stringWithFormat:@"%@ to %@",endModel.dateValue,startModel.dateValue];
//    [self.monthlyHeader setViewModel:self.monthlyHeaderModel];
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
        _monthlyHeaderModel.energyValue = @"0";
        _monthlyHeaderModel.timeMsg = @"Date";
        _monthlyHeaderModel.dateMsg = [self fetchHeaderModelDate];
    }
    return _monthlyHeaderModel;
}

- (NSDictionary *)parseCurrentEnergyDatas:(NSDictionary *)energyDic {
    NSString *dateInfo = energyDic[@"timestamp"];
    NSArray *timeList = [dateInfo componentsSeparatedByString:@"&"];
    NSArray *dateList = [timeList[0] componentsSeparatedByString:@"-"];
    NSArray *hourList = [timeList[1] componentsSeparatedByString:@":"];
    NSString *year = dateList[0];
    NSString *month = dateList[1];
    if (month.length == 1) {
        month = [@"0" stringByAppendingString:month];
    }
    NSString *day = dateList[2];
    if (day.length == 1) {
        day = [@"0" stringByAppendingString:day];
    }
    NSString *hour = hourList[0];
    if (hour.length == 1) {
        hour = [@"0" stringByAppendingString:hour];
    }
    NSDictionary *dateDic = @{
        @"year":year,
        @"month":month,
        @"day":day,
        @"hour":hour,
    };
    NSString *totalValue = [NSString stringWithFormat:@"%ld",(long)[energyDic[@"all_energy"] integerValue]];
    NSString *monthlyValue = [NSString stringWithFormat:@"%ld",(long)[energyDic[@"thirty_day_energy"] integerValue]];
    NSString *currentDayValue = [NSString stringWithFormat:@"%ld",(long)[energyDic[@"today_energy"] integerValue]];
    NSString *currentHourValue = [NSString stringWithFormat:@"%ld",(long)[energyDic[@"current_hour_energy"] integerValue]];
    return @{
        @"date":dateDic,
        @"totalValue":totalValue,
        @"monthlyValue":monthlyValue,
        @"currentDayValue":currentDayValue,
        @"currentHourValue":currentHourValue,
    };
}

- (NSString *)fetchHeaderModelDate {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *endDateString = [dateFormat stringFromDate:date];
    NSInteger second = 24 * 60 * 60;
    NSDate *lastDate = [date initWithTimeIntervalSinceNow:(-29 * second)];
    NSString *startDateString = [dateFormat stringFromDate:lastDate];
    return [NSString stringWithFormat:@"%@ to %@",startDateString,endDateString];
}

@end
