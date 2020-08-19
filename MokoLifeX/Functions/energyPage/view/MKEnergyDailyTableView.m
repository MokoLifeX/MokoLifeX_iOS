//
//  MKEnergyDailyTableView.m
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKEnergyDailyTableView.h"
#import "MKEnergyTableHeaderView.h"
#import "MKEnergyValueCell.h"
#import "MKEnergyValueCellModel.h"

@interface MKEnergyDailyTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *dailyTableView;

@property (nonatomic, strong)MKEnergyTableHeaderView *dailyTableHeader;

@property (nonatomic, strong)MKEnergyTableHeaderViewModel *dailyHeaderModel;

@property (nonatomic, strong)NSMutableArray *dailyList;

@property (nonatomic, assign)CGFloat pulseConstant;

@end

@implementation MKEnergyDailyTableView

- (void)dealloc {
    NSLog(@"MKEnergyDailyTableView销毁");
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.dailyTableView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveCurrentEnergyNotification:)
                                                     name:MKMQTTServerReceivedCurrentEnergyNotification
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.dailyTableView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    return self.dailyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKEnergyValueCell *cell = [MKEnergyValueCell initCellWithTableView:tableView];
    cell.dataModel = self.dailyList[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)receiveCurrentEnergyNotification:(NSNotification *)note {
    NSDictionary *energyDic = [self parseCurrentEnergyDatas:note.userInfo[@"userInfo"]];
    NSString *hour = energyDic[@"date"][@"hour"];
    NSString *minutes = energyDic[@"date"][@"minutes"];
    NSString *seconds = energyDic[@"date"][@"seconds"];
    //如果发过来的时间是XX:00:00,这个电能值是XX上一个小时的值
    BOOL isLastOn = ([minutes isEqualToString:@"00"] && [seconds isEqualToString:@"00"]);
    if (self.dailyList.count == 0) {
        //没有直接添加
        MKEnergyValueCellModel *newModel = [[MKEnergyValueCellModel alloc] init];
        if (isLastOn) {
            NSInteger tempHour = [hour integerValue] - 1;
            if (tempHour < 0) {
                tempHour = 0;
            }
            NSString *tempHourString = [NSString stringWithFormat:@"%ld",(long)tempHour];
            if (tempHourString.length == 1) {
                tempHourString = [@"0" stringByAppendingString:tempHourString];
            }
            newModel.timeValue = tempHourString;
        }else {
            newModel.timeValue = hour;
        }
        newModel.energyValue = energyDic[@"currentHourValue"];
        [self.dailyList addObject:newModel];
    }else {
        NSString *keyHour = hour;
        if (isLastOn) {
            NSInteger tempHour = [hour integerValue] - 1;
            if (tempHour < 0) {
                tempHour = 0;
            }
            keyHour = [NSString stringWithFormat:@"%ld",(long)tempHour];
            if (keyHour.length == 1) {
                keyHour = [@"0" stringByAppendingString:keyHour];
            }
        }
        BOOL contain = NO;
        for (NSInteger i = 0; i < self.dailyList.count; i ++) {
            MKEnergyValueCellModel *model = self.dailyList[i];
            if ([model.timeValue isEqualToString:keyHour]) {
                //存在，替换
                model.energyValue = energyDic[@"currentHourValue"];
                contain = YES;
                break;
            }
        }
        if (!contain) {
            //没有，添加
            MKEnergyValueCellModel *newModel = [[MKEnergyValueCellModel alloc] init];
            newModel.timeValue = keyHour;
            newModel.energyValue = energyDic[@"currentHourValue"];
            [self.dailyList insertObject:newModel atIndex:0];
        }
    }
    [self.dailyTableView reloadData];
    [self reloadHeaderViewWithEnergy:[energyDic[@"currentDayValue"] floatValue]];
}

#pragma mark - public method

- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant {
    self.pulseConstant = [pulseConstant floatValue];
    if (energyList.count == 0) {
        return;
    }
    [self.dailyList removeAllObjects];
    NSUInteger totalValue = 0;
    for (NSInteger i = energyList.count - 1; i >= 0; i --) {
        NSDictionary *dic = energyList[i];
        MKEnergyValueCellModel *model = [[MKEnergyValueCellModel alloc] init];
        NSString *timeValue = dic[@"index"];
        model.timeValue = (timeValue.length == 1 ? [@"0" stringByAppendingString:timeValue] : timeValue);
        model.energyValue = dic[@"rotationsNumber"];
        totalValue += [dic[@"rotationsNumber"] integerValue];
        [self.dailyList addObject:model];
    }
    [self.dailyTableView reloadData];
    [self reloadHeaderViewWithEnergy:(totalValue * 1.f)];
}

- (void)resetAllDatas {
    [self.dailyList removeAllObjects];
    [self.dailyTableView reloadData];
    self.dailyHeaderModel.energyValue = @"0.0";
    self.dailyHeaderModel.dateMsg = [NSString stringWithFormat:@"00:00 to 00:00,%@",[self fetchCurrentDate]];
    [self.dailyTableHeader setViewModel:self.dailyHeaderModel];
}

#pragma mark - private method
- (void)reloadHeaderViewWithEnergy:(float)energy {
    self.dailyHeaderModel.energyValue = (self.pulseConstant == 0 ? @"0" : [NSString stringWithFormat:@"%.2f",energy / self.pulseConstant]);
    NSString *date = [self fetchCurrentDate];
    NSString *tempHour = @"00";
    if (self.dailyList.count > 0) {
        MKEnergyValueCellModel *model = self.dailyList.firstObject;
        tempHour = model.timeValue;
    }
    self.dailyHeaderModel.dateMsg = [NSString stringWithFormat:@"00:00 to %@:00,%@",tempHour,date];
    [self.dailyTableHeader setViewModel:self.dailyHeaderModel];
}

#pragma mark - getter
- (MKBaseTableView *)dailyTableView {
    if (!_dailyTableView) {
        _dailyTableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _dailyTableView.backgroundColor = COLOR_WHITE_MACROS;
        _dailyTableView.delegate = self;
        _dailyTableView.dataSource = self;
        _dailyTableView.tableHeaderView = self.dailyTableHeader;
    }
    return _dailyTableView;
}

- (NSMutableArray *)dailyList {
    if (!_dailyList) {
        _dailyList = [NSMutableArray array];
    }
    return _dailyList;
}

- (MKEnergyTableHeaderView *)dailyTableHeader {
    if (!_dailyTableHeader) {
        _dailyTableHeader = [[MKEnergyTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 230.f)];
        _dailyTableHeader.viewModel = self.dailyHeaderModel;
    }
    return _dailyTableHeader;
}

- (MKEnergyTableHeaderViewModel *)dailyHeaderModel {
    if (!_dailyHeaderModel) {
        _dailyHeaderModel = [[MKEnergyTableHeaderViewModel alloc] init];
        _dailyHeaderModel.energyValue = @"0";
        _dailyHeaderModel.timeMsg = @"Hour";
    }
    return _dailyHeaderModel;
}

- (NSString *)fetchCurrentDate {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormat stringFromDate:[NSDate date]];
    return date;
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
    NSString *minutes = hourList[1];
    if (minutes.length == 1) {
        minutes = [@"0" stringByAppendingString:minutes];
    }
    NSString *seconds = hourList[2];
    if (seconds.length == 1) {
        seconds = [@"0" stringByAppendingString:seconds];
    }
    NSDictionary *dateDic = @{
        @"year":year,
        @"month":month,
        @"day":day,
        @"hour":hour,
        @"minutes":minutes,
        @"seconds":seconds
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

@end
