//
//  MKEnergyDataModel.m
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKEnergyDataModel.h"

@interface MKEnergyDataModel ()

@property (nonatomic, strong)dispatch_queue_t readQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

@property (nonatomic, strong)NSArray *dailyList;

@property (nonatomic, strong)NSArray *monthlyList;

@property (nonatomic, copy)NSString *pulseConstant;

@property (nonatomic, copy)NSString *totalEnergy;

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@property (nonatomic, copy)MKEnergyDataModelSucBlock sucBlock;

@property (nonatomic, copy)MKEnergyDataModelFailedBlock failedBlock;

@property (nonatomic, assign)NSInteger dataCount;

@end

@implementation MKEnergyDataModel

#pragma mark - notes
- (void)receiveServerDatas:(NSNotification *)note {
    if (self.readTimeout) {
        return;
    }
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"id"] isEqualToString:MKDeviceModelManager.shared.mqttID]) {
        return;
    }
    
    if ([deviceDic[@"function"] integerValue] == 1014) {
        //累计电能
        self.dataCount ++;
        NSArray *dateList = [deviceDic[@"timestamp"] componentsSeparatedByString:@" "];
        self.monthlyList = [self parseMonthList:dateList[0] dataList:deviceDic[@"result"]];
        [self hasSuccess];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1015) {
        //今天电能
        self.dataCount ++;
        self.dailyList = [self parseDaily:deviceDic[@"result"]];
        [self hasSuccess];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1016) {
        //脉冲常数
        self.dataCount ++;
        self.pulseConstant = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"EC"] integerValue]];
        [self hasSuccess];
        return;
    }
    if ([deviceDic[@"function"] integerValue] == 1017) {
        //总累计电能
        self.dataCount ++;
        self.totalEnergy = [NSString stringWithFormat:@"%ld",(long)[deviceDic[@"all_energy"] integerValue]];
        [self hasSuccess];
        return;
    }
}

#pragma mark - Public method
- (void)startReadEnergyDatasWithScuBlock:(MKEnergyDataModelSucBlock)sucBlock
                             failedBlock:(MKEnergyDataModelFailedBlock)failedBlock {
    self.sucBlock = nil;
    self.sucBlock = sucBlock;
    self.failedBlock = nil;
    self.failedBlock = failedBlock;
    dispatch_async(self.readQueue, ^{
        if (![self readPulseConstant]) {
            [self operationFailedBlockWithMsg:@"Read pulseConstant error"];
            return ;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveServerDatas:)
                                                     name:MKMQTTServerReceivedPulseConstantNotification
                                                   object:nil];
        if (![self readMonthlyList]) {
            [self operationFailedBlockWithMsg:@"Read monthly data error"];
            return ;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveServerDatas:)
                                                     name:MKMQTTServerReceivedHistoricalEnergyNotification
                                                   object:nil];
        if (![self readDailyList]) {
            [self operationFailedBlockWithMsg:@"Read daily data error"];
            return ;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveServerDatas:)
                                                     name:MKMQTTServerReceivedEnergyDataOfTodayNotification
                                                   object:nil];
        if (![self readTotalEnergy]) {
            [self operationFailedBlockWithMsg:@"Read total energy data error"];
            return;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveServerDatas:)
                                                     name:MKMQTTServerReceivedTotalEnergyNotification
                                                   object:nil];
        moko_dispatch_main_safe(^{
            [self initReadTimer];
        });
    });
}

#pragma mark - interface
- (BOOL)readPulseConstant {
    __block BOOL success = NO;
    [MKMQTTServerInterface readPulseConstantWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readMonthlyList {
    __block BOOL success = NO;
    [MKMQTTServerInterface readHistoricalEnergyWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readDailyList {
    __block BOOL success = NO;
    [MKMQTTServerInterface readEnergyDataOfTodayWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)readTotalEnergy {
    __block BOOL success = NO;
    [MKMQTTServerInterface readTotalEnergyWithTopic:MKDeviceModelManager.shared.subTopic mqttID:MKDeviceModelManager.shared.mqttID sucBlock:^{
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError * _Nonnull error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark - private method
- (void)operationFailedBlockWithMsg:(NSString *)msg {
    moko_dispatch_main_safe(^{
        NSError *error = [[NSError alloc] initWithDomain:@"readEnergyData"
                                                    code:-999
                                                userInfo:@{@"errorInfo":SafeStr(msg)}];
        if (self.failedBlock) {
            self.failedBlock(error);
        }
    })
}

- (void)hasSuccess {
    if (self.dataCount < 4 || self.readTimeout) {
        return;
    }
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
    if (self.sucBlock) {
        self.sucBlock(self.dailyList, self.monthlyList, self.pulseConstant, self.totalEnergy);
    }
}

- (void)initReadTimer{
    self.readTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0,
                                            0,
                                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 10.f * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10.f * NSEC_PER_SEC;
    dispatch_source_set_timer(self.readTimer, start, interval, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.readTimer, ^{
        weakSelf.readTimeout = YES;
        dispatch_cancel(weakSelf.readTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] removeObserver:self];
            [self operationFailedBlockWithMsg:@"Read data timeout"];
        });
    });
    dispatch_resume(self.readTimer);
}

- (NSArray *)parseMonthList:(NSString *)timestamp dataList:(NSArray *)dataList {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *recordDate = [dateFormat dateFromString:timestamp];
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *dic in dataList) {
        NSInteger index = [dic[@"offset"] integerValue];
        NSDate *tempDate = [[NSDate alloc] initWithTimeInterval:(24 * 60 * 60 * index) sinceDate:recordDate];
        NSString *tempTime = [dateFormat stringFromDate:tempDate];
        NSDictionary *tempDic = @{
            @"date":tempTime,
            @"rotationsNumber":[NSString stringWithFormat:@"%ld",(long)[dic[@"value"] integerValue]],
            @"index":[NSString stringWithFormat:@"%ld",(long)index],
        };
        [list addObject:tempDic];
    }
    return list;
}

- (NSArray *)parseDaily:(NSArray *)dataList {
    NSMutableArray *list = [NSMutableArray array];
    for (NSDictionary *tempDic in dataList) {
        NSDictionary *dic = @{
            @"index":[NSString stringWithFormat:@"%ld",(long)[tempDic[@"offset"] integerValue]],
            @"rotationsNumber":[NSString stringWithFormat:@"%ld",(long)[tempDic[@"value"] integerValue]],
        };
        [list addObject:dic];
    }
    return list;
}

#pragma mark - getter
- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (dispatch_queue_t)readQueue {
    if (!_readQueue) {
        _readQueue = dispatch_queue_create("readParamsQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _readQueue;
}

@end
