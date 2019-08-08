//
//  MKModifyPowerOnStatusController.m
//  MokoLifeX
//
//  Created by aa on 2019/8/8.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKModifyPowerOnStatusController.h"

@interface MKModifyPowerOnStatusController ()

@end

@implementation MKModifyPowerOnStatusController

- (void)dealloc {
    NSLog(@"MKModifyPowerOnStatusController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    // Do any additional setup after loading the view.
}

#pragma mark - UI
- (void)loadSubViews {
    self.custom_naviBarColor = UIColorFromRGB(0x0188cc);
    self.titleLabel.textColor = COLOR_WHITE_MACROS;
    self.defaultTitle = @"Modify power on status";
}

@end
