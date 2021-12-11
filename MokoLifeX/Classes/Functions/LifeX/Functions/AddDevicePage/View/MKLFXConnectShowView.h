//
//  MKLFXConnectShowView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/20.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXConnectShowView : UIView

- (void)showWithConfirmBlock:(void (^)(void))confirmBlock;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
