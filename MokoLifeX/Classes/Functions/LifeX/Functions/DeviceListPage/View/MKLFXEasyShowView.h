//
//  MKLFXEasyShowView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXEasyShowView : UIView

- (void)showText:(NSString *)text
       superView:(UIView *)superView
        animated:(BOOL)animated;

- (void)hidden;

@end

NS_ASSUME_NONNULL_END
