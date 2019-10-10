//
//  MKAppDelegate.m
//  MokoLifeXSDK
//
//  Created by aadyx2007@163.com on 09/27/2019.
//  Copyright (c) 2019 aadyx2007@163.com. All rights reserved.
//

#import "MKAppDelegate.h"
#import "MKDeviceListController.h"

#import "FLAnimatedImageView+WebCache.h"
#import "MKLaunchScreenView.h"

@interface MKAppDelegate ()<MKLaunchScreenViewDelegate>

@property (nonatomic, strong)MKLaunchScreenView* launchImageView;

@end

@implementation MKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = COLOR_GREEN_MARCROS;
    //加载网络部分
    [MKMQTTServerDataManager sharedInstance];
    [MKNetworkManager sharedInstance];
    [self enterAddDevicePage];
    [self showLaunchImageView];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - MKLaunchScreenViewDelegate
- (void)launchScreenViewRemoveButtonPressed {
    if (!self.launchImageView || !self.launchImageView.superview) {
        return;
    }
    [UIView animateWithDuration:.5f animations:^{
        self.launchImageView.alpha = 0.0;
        self.launchImageView.transform = CGAffineTransformMakeScale(1.2, 1.2);
     }completion:^(BOOL finished) {
        [self.launchImageView removeFromSuperview];
         self.launchImageView = nil;
    }];
}

#pragma mark -
- (void)enterAddDevicePage{
    MKDeviceListController *vc = [[MKDeviceListController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
}

//启动动画
-(void)showLaunchImageView{
    MKLaunchScreenView* launchImageView = [[MKLaunchScreenView alloc]initWithFrame:self.window.bounds];
    launchImageView.delegate = self;
    self.launchImageView = launchImageView;
    NSURL *gifUrl = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1569669275190&di=e79cb72351f7149fc96b3f701fb8a4c6&imgtype=0&src=http%3A%2F%2Fp2.so.qhmsg.com%2Ft0182f2bfa9e50d0787.gif"];
    [launchImageView sd_setImageWithURL:gifUrl placeholderImage:[self getLaunchImage]];
    [self.window addSubview:launchImageView];
    [self.window bringSubviewToFront:launchImageView];
  
    [self performSelector:@selector(launchScreenViewRemoveButtonPressed) withObject:nil afterDelay:5.f];
}

//

//根据屏幕尺寸自动选择合适尺寸的启动图片
-(UIImage*)getLaunchImage{
    NSString *imageName = @"startFullIcon-5";
    if (iPhone6){
        imageName = @"startFullIcon-6";
    }else if (iPhone6Plus){
        imageName = @"startFullIcon-6P";
    }else if (iPhoneX){
        imageName = @"startFullIcon-x";
    }else if (iPhoneXR){
        imageName = @"startFullIcon-xr";
    }else if (iPhoneMax){
        imageName = @"startFullIcon-xsm.png";
    }
    UIImage *launchImage = [UIImage imageNamed:imageName];
    return launchImage;
}

#pragma mark - setter & getter

@end
