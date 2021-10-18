//
//  MKLFXBEnergyDailyTableView.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBEnergyDailyTableView.h"

#import "Masonry.h"

#import "MKMacroDefines.h"
#import "MKBaseTableView.h"
#import "UIView+MKAdd.h"

#import "MKLFXEnergyValueCell.h"
#import "MKLFXEnergyTableHeaderView.h"

@interface MKLFXBEnergyDailyTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)MKLFXEnergyTableHeaderView *tableHeaderView;

@property (nonatomic, strong)MKLFXEnergyTableHeaderViewModel *headerModel;

@property (nonatomic, assign)CGFloat pulseConstant;

@property (nonatomic, copy)NSString *deviceID;

@end

@implementation MKLFXBEnergyDailyTableView

- (void)dealloc {
    NSLog(@"MKLFXBEnergyDailyTableView销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithDeviceID:(NSString *)deviceID currentEnergyNotificationName:(NSString *)name {
    if (self = [super init]) {
        self.deviceID = deviceID;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveCurrentEnergy:)
                                                     name:name
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MKLFXEnergyValueCell *cell = [MKLFXEnergyValueCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - note
- (void)receiveCurrentEnergy:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (!ValidDict(userInfo) || ![userInfo[@"id"] isEqualToString:self.deviceID] || [userInfo[@"msg_id"] integerValue] != 1018) {
        return;
    }
    NSDictionary *energyDic = [self parseCurrentEnergyDatas:userInfo[@"data"]];
    NSString *hour = energyDic[@"date"][@"hour"];
    NSString *minutes = energyDic[@"date"][@"minutes"];
    NSString *seconds = energyDic[@"date"][@"seconds"];
    //如果发过来的时间是XX:00:00,这个电能值是XX上一个小时的值
    BOOL isLastOn = ([minutes isEqualToString:@"00"] && [seconds isEqualToString:@"00"]);
    if (self.dataList.count == 0) {
        //没有直接添加
        MKLFXEnergyValueCellModel *newModel = [[MKLFXEnergyValueCellModel alloc] init];
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
        [self.dataList addObject:newModel];
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
        for (NSInteger i = 0; i < self.dataList.count; i ++) {
            MKLFXEnergyValueCellModel *model = self.dataList[i];
            if ([model.timeValue isEqualToString:keyHour]) {
                //存在，替换
                model.energyValue = energyDic[@"currentHourValue"];
                contain = YES;
                break;
            }
        }
        if (!contain) {
            //没有，添加
            MKLFXEnergyValueCellModel *newModel = [[MKLFXEnergyValueCellModel alloc] init];
            newModel.timeValue = keyHour;
            newModel.energyValue = energyDic[@"currentHourValue"];
            [self.dataList insertObject:newModel atIndex:0];
        }
    }
    [self.tableView reloadData];
    [self reloadHeaderViewWithEnergy:[energyDic[@"currentDayValue"] floatValue]];
}

#pragma mark - public method
- (void)updateEnergyDatas:(NSArray *)energyList pulseConstant:(NSString *)pulseConstant {
    self.pulseConstant = [pulseConstant floatValue];
    if (energyList.count == 0) {
        return;
    }
    [self.dataList removeAllObjects];
    NSUInteger totalValue = 0;
    for (NSInteger i = energyList.count - 1; i >= 0; i --) {
        NSDictionary *dic = energyList[i];
        MKLFXEnergyValueCellModel *model = [[MKLFXEnergyValueCellModel alloc] init];
        NSString *timeValue = dic[@"index"];
        model.timeValue = (timeValue.length == 1 ? [@"0" stringByAppendingString:timeValue] : timeValue);
        model.energyValue = dic[@"rotationsNumber"];
        totalValue += [dic[@"rotationsNumber"] integerValue];
        [self.dataList addObject:model];
    }
    [self.tableView reloadData];
    [self reloadHeaderViewWithEnergy:(totalValue * 1.f)];
}

- (void)resetAllDatas {
    [self.dataList removeAllObjects];
    [self.tableView reloadData];
    self.headerModel.energyValue = @"0.0";
    self.headerModel.dateMsg = [NSString stringWithFormat:@"00:00 to 00:00,%@",[self fetchCurrentDate]];
    [self.tableHeaderView setDataModel:self.headerModel];
}

#pragma mark - private method
- (void)reloadHeaderViewWithEnergy:(float)energy {
    self.headerModel.energyValue = (self.pulseConstant == 0 ? @"0" : [NSString stringWithFormat:@"%.2f",energy / self.pulseConstant]);
    NSString *date = [self fetchCurrentDate];
    NSString *tempHour = @"00";
    if (self.dataList.count > 0) {
        MKLFXEnergyValueCellModel *model = self.dataList.firstObject;
        tempHour = model.timeValue;
    }
    self.headerModel.dateMsg = [NSString stringWithFormat:@"00:00 to %@:00,%@",tempHour,date];
    [self.tableHeaderView setDataModel:self.headerModel];
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

#pragma mark - getter
- (MKBaseTableView *)tableView {
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.tableHeaderView;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (MKLFXEnergyTableHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[MKLFXEnergyTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, kViewWidth, 230.f)];
    }
    return _tableHeaderView;
}

- (MKLFXEnergyTableHeaderViewModel *)headerModel {
    if (!_headerModel) {
        _headerModel = [[MKLFXEnergyTableHeaderViewModel alloc] init];
        _headerModel.energyValue = @"0";
        _headerModel.timeMsg = @"Hour";
    }
    return _headerModel;
}

@end
