//
//  MKAppDelegate.m
//  MokoLifeX
//
//  Created by aadyx2007@163.com on 08/19/2021.
//  Copyright (c) 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKAppDelegate.h"

#import <CoreLocation/CoreLocation.h>

#import "MKLFXDeviceListController.h"

@interface MKAppDelegate ()

@property (nonatomic, strong)CLLocationManager *locationManager;

@property (nonatomic, strong)UIView *launchView;

@end

@implementation MKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _window.backgroundColor = [UIColor whiteColor];
    MKLFXDeviceListController *vc = [[MKLFXDeviceListController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    _window.rootViewController = nav;
    [_window makeKeyAndVisible];
    [self addLaunchScreen];
    [self addLocationAuth];
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

#pragma mark - private method
- (void)addLaunchScreen {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil] instantiateViewControllerWithIdentifier:@"LaunchImageBoard"];
    self.launchView = viewController.view;
    [self.window addSubview:self.launchView];
    [self.window bringSubviewToFront:self.launchView];
    
    [self performSelector:@selector(launchViewRemoved) withObject:nil afterDelay:.2f];
}

- (void)launchViewRemoved {
    if (!self.launchView || !self.launchView.superview) {
        return;
    }
    [UIView animateWithDuration:.2f animations:^{
        self.launchView.alpha = 0.0;
        self.launchView.transform = CGAffineTransformMakeScale(1.2, 1.2);
     }completion:^(BOOL finished) {
        [self.launchView removeFromSuperview];
         self.launchView = nil;
    }];
}

- (void)addLocationAuth {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 13) {
        return;
    }
    //iOS13版本系统新增位置权限
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    }
}

@end
