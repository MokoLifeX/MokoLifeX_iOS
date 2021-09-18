//
//  MKLFXBSwitchViewButton.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/31.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBSwitchViewButtonModel : NSObject

@property (nonatomic, strong)UIImage *icon;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, strong)UIColor *msgColor;

@end

@interface MKLFXBSwitchViewButton : UIControl

@property (nonatomic, strong)MKLFXBSwitchViewButtonModel *dataModel;

@end

NS_ASSUME_NONNULL_END
