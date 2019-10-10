//
//  MKLaunchScreenView.h
//  MokoLifeXSDK_Example
//
//  Created by aa on 2019/9/28.
//  Copyright © 2019 aadyx2007@163.com. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLaunchScreenViewDelegate <NSObject>

- (void)launchScreenViewRemoveButtonPressed;

@end

@interface MKLaunchScreenView : FLAnimatedImageView

@property (nonatomic, weak)id <MKLaunchScreenViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
