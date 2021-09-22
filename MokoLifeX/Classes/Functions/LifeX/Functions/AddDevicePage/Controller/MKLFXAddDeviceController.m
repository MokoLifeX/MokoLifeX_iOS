//
//  MKLFXAddDeviceController.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/20.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXAddDeviceController.h"

#import "Masonry.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "MKMacroDefines.h"
#import "NSString+MKAdd.h"
#import "UIView+MKAdd.h"

#import "MKHudManager.h"
#import "MKCustomUIAdopter.h"

#import "MKNetworkManager.h"

#import "MKLFXSocketManager.h"

#import "CTMediator+MKLFXAdd.h"

#import "MKLFXConnectShowView.h"

#import "MKLFXOperationStepsController.h"

@interface MKLFXAddDeviceController ()

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)FLAnimatedImageView *centerIcon;

@property (nonatomic, strong)UIControl *blinkButton;

@property (nonatomic, strong)UIButton *indicatorButton;

@end

@implementation MKLFXAddDeviceController

- (void)dealloc {
    NSLog(@"MKLFXAddDeviceController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
}

#pragma mark - event method
- (void)blinkButtonPressed {
    MKLFXOperationStepsController *vc = [[MKLFXOperationStepsController alloc] init];
    @weakify(self);
    vc.indicatorButtonPressedBlock = ^{
        @strongify(self);
        [self indicatorButtonPressed];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)indicatorButtonPressed {
    if ([MKNetworkManager currentWifiIsCorrect]) {
        //如果当前连接的wifi是设备，则直接读取设备类型
        [self connectDevice];
        return;
    }
    MKLFXConnectShowView *view = [[MKLFXConnectShowView alloc] init];
    [view showWithConfirmBlock:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                           options:@{}
                                 completionHandler:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkChanged)
                                                     name:MKNetworkStatusChangedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(networkChanged)
                                           name:UIApplicationDidBecomeActiveNotification
                                         object:nil];
    }];
}

#pragma mark - note
- (void)networkChanged {
    if (![MKNetworkManager currentWifiIsCorrect]) {
        return;
    }
    //如果当前连接的wifi是设备，则直接读取设备类型
    [self connectDevice];
}

#pragma mark - private method
- (void)connectDevice {
    [[MKHudManager share] showHUDWithTitle:@"Connecting..." inView:self.view isPenetration:NO];
    [[MKLFXSocketManager shared] connectWithHost:lfx_defaultHostIpAddress port:lfx_defaultPort sucBlock:^{
        if (![MKBaseViewController isCurrentViewControllerVisible:self]) {
            //判断当前页面是不是第一个
            [[MKHudManager share] hide];
            return;
        }
        [self performSelector:@selector(readDeviceType) withObject:nil afterDelay:2.f];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)readDeviceType {
    [[MKHudManager share] showHUDWithTitle:@"Reading..." inView:self.view isPenetration:NO];
    [[MKLFXSocketManager shared] readDeviceInfoWithSucBlock:^(id  _Nonnull returnData) {
        [[MKHudManager share] hide];
        [self pushMQTTForDevicePage:returnData[@"result"]];
    } failedBlock:^(NSError * _Nonnull error) {
        [[MKHudManager share] hide];
        [self.view showCentralToast:error.userInfo[@"errorInfo"]];
    }];
}

- (void)pushMQTTForDevicePage:(NSDictionary *)deviceInfo {
    UIViewController *vc = [[CTMediator sharedInstance] CTMediator_MokoLifeX_ServerForDevicePage:deviceInfo];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI
- (void)loadSubViews {
    self.defaultTitle = @"Add Device";
    self.view.backgroundColor = RGBCOLOR(239, 239, 239);
    CGSize msgSize = [NSString sizeWithText:self.msgLabel.text
                                    andFont:self.msgLabel.font
                                 andMaxSize:CGSizeMake(kViewWidth - 2 * 30.f, MAXFLOAT)];
    [self.view addSubview:self.msgLabel];
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30.f);
        make.right.mas_equalTo(-30.f);
        make.top.mas_equalTo(defaultTopInset + 20.f);
        make.height.mas_equalTo(msgSize.height);
    }];
    [self.view addSubview:self.centerIcon];
    [self.centerIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(144.f);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(253.f);
    }];
    [self.view addSubview:self.blinkButton];
    [self.blinkButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(190.f);
        make.top.mas_equalTo(self.centerIcon.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(35.f);
    }];
    [self.view addSubview:self.indicatorButton];
    [self.indicatorButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20.f);
        make.right.mas_equalTo(-20.f);
        make.top.mas_equalTo(self.blinkButton.mas_bottom).mas_offset(30.f);
        make.height.mas_equalTo(40.f);
    }];
}

#pragma mark - getter
- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = RGBCOLOR(143, 143, 143);
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.font = MKFont(13.f);
        _msgLabel.text = @"Plug in the device and confirm that indicator is blinking amber";
        _msgLabel.numberOfLines = 0;
    }
    return _msgLabel;
}

- (FLAnimatedImageView *)centerIcon {
    if (!_centerIcon) {
        _centerIcon = [[FLAnimatedImageView alloc] init];
        NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"MKLFXAddDeviceController")];
        NSString *bundlePath = [bundle pathForResource:@"MokoLifeX" ofType:@"bundle"];
        
        NSString *filePath = [bundlePath stringByAppendingPathComponent:@"lfx_addDeviceCenterGif.gif"];
        NSData* imageData = [NSData dataWithContentsOfFile:filePath];
        _centerIcon.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
    }
    return _centerIcon;
}

- (UIControl *)blinkButton {
    if (!_blinkButton) {
        _blinkButton = [[UIControl alloc] init];
        [_blinkButton addTarget:self
                         action:@selector(blinkButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *buttonLabel = [[UILabel alloc] init];
        buttonLabel.textColor = NAVBAR_COLOR_MACROS;
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        buttonLabel.font = MKFont(14.f);
        buttonLabel.text = @"My light is not blinking amber";
        [_blinkButton addSubview:buttonLabel];
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = NAVBAR_COLOR_MACROS;
        [_blinkButton addSubview:lineView];
        
        [buttonLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(15.f);
            make.height.mas_equalTo(MKFont(12.f).lineHeight);
        }];
        [lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(buttonLabel.mas_bottom);
            make.height.mas_equalTo(CUTTING_LINE_HEIGHT);
        }];
    }
    return _blinkButton;
}

- (UIButton *)indicatorButton {
    if (!_indicatorButton) {
        _indicatorButton = [MKCustomUIAdopter customButtonWithTitle:@"Indicator blink amber light"
                                                             target:self
                                                             action:@selector(indicatorButtonPressed)];
        _indicatorButton.titleLabel.font = MKFont(16.f);
    }
    return _indicatorButton;
}

@end
