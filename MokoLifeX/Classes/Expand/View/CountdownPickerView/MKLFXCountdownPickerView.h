//
//  MKLFXCountdownPickerView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/2.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCountdownPickerViewModel : NSObject

@property (nonatomic, copy)NSString *hour;

@property (nonatomic, copy)NSString *minutes;

@property (nonatomic, copy)NSString *titleMsg;

@end

@interface MKLFXCountdownPickerView : UIView

@property (nonatomic, strong)MKLFXCountdownPickerViewModel *timeModel;

- (void)showTimePickViewBlock:(void (^)(MKLFXCountdownPickerViewModel *timeModel))Block;

@end

NS_ASSUME_NONNULL_END
