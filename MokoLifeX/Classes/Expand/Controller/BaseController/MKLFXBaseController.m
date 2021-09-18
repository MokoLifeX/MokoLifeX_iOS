//
//  MKLFXBaseController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/1.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBaseController.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"

#import "MKLFXDeviceModel.h"

@interface MKLFXBaseController ()

/**
 定时器，超过指定时间将会视为读取失败
 */
@property (nonatomic, strong)dispatch_source_t readTimer;

/**
 超时标记
 */
@property (nonatomic, assign)BOOL readTimeout;

@end

@implementation MKLFXBaseController

- (void)dealloc {
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)startReadTimer {
    self.readTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                            0,
                                            0,
                                            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 10.f * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10.f * NSEC_PER_SEC;
    dispatch_source_set_timer(self.readTimer, start, interval, 0);
    @weakify(self);
    dispatch_source_set_event_handler(self.readTimer, ^{
        @strongify(self);
        self.readTimeout = YES;
        dispatch_cancel(self.readTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self readDataTimeout];
        });
    });
    dispatch_resume(self.readTimer);
}

- (void)readDataTimeout {
    [[MKHudManager share] hide];
    [self.view showCentralToast:@"Read data timeout!"];
    [self performSelector:@selector(leftButtonMethod) withObject:nil afterDelay:0.5f];
}

- (void)cancelTimer {
    if (self.readTimer) {
        dispatch_cancel(self.readTimer);
    }
}

@end
