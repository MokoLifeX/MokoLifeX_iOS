//
//  MKDeviceModelManager.m
//  MokoLifeX
//
//  Created by aa on 2020/6/18.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKDeviceModelManager.h"

static MKDeviceModelManager *manager = nil;

@interface MKDeviceModelManager ()

@property (nonatomic, strong)MKDeviceModel *deviceModel;

@end

@implementation MKDeviceModelManager

+ (MKDeviceModelManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[MKDeviceModelManager alloc] init];
        }
    });
    return manager;
}

- (void)managementDeviceModel:(MKDeviceModel *)deviceModel {
    self.deviceModel = nil;
    self.deviceModel = deviceModel;
    if (!deviceModel) {
        return;
    }
    WS(weakSelf);
    [self.deviceModel addObserverBlockForKeyPath:@"plugState" block:^(id  _Nonnull obj, id  _Nullable oldVal, id  _Nullable newVal) {
        moko_dispatch_main_safe(^{
            if ([weakSelf.delegate respondsToSelector:@selector(currentDeviceModelStateChanged:)]) {
                [weakSelf.delegate currentDeviceModelStateChanged:[newVal integerValue]];
            }
        });
    }];
}

- (void)clearManagementModel {
    if (self.deviceModel) {
        [self.deviceModel removeObserverBlocksForKeyPath:@"plugState"];
    }
    self.deviceModel = nil;
    self.delegate = nil;
}

- (NSString *)subTopic {
    if (!self.deviceModel) {
        return @"";
    }
    return [self.deviceModel currentSubscribedTopic];
}

@end
