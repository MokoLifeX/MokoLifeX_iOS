//
//  MKLFXCBaseController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/16.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCBaseController.h"

#import "MKMacroDefines.h"
#import "UIView+MKAdd.h"

#import "MKLFXDeviceModel.h"

#import "MKLFXCMQTTManager.h"
#import "MKLFXCMQTTInterface.h"

@interface MKLFXCBaseController ()

@end

@implementation MKLFXCBaseController

- (void)dealloc {
    NSLog(@"MKLFXCBaseController销毁");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveLoadChanged:)
                                                 name:MKLFXCReceiveLoadChangeStatusNotification
                                               object:nil];
}

- (void)receiveLoadChanged:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    if (self.readTimeout || !ValidDict(userInfo) || !ValidStr(userInfo[@"id"]) || ![userInfo[@"id"] isEqualToString:self.deviceModel.deviceID] || [userInfo[@"msg_id"] integerValue] != 1011) {
        return;
    }
    if (![MKBaseViewController isCurrentViewControllerVisible:self]) {
        return;
    }
    BOOL load = ([userInfo[@"data"][@"load"] integerValue] == 1);
    NSString *msg = (load ? @"Load starts work!" : @"Load stops work!");
    [self.view showCentralToast:msg];
}

@end
