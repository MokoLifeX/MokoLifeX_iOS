//
//  MKLFXASwitchViewButton.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXASwitchViewButtonModel : NSObject

@property (nonatomic, strong)UIImage *icon;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, strong)UIColor *msgColor;

@end

@interface MKLFXASwitchViewButton : UIControl

@property (nonatomic, strong)MKLFXASwitchViewButtonModel *dataModel;

@end

NS_ASSUME_NONNULL_END
