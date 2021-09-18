//
//  MKLFXEnergyTableHeaderView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXEnergyTableHeaderViewModel : NSObject

@property (nonatomic, copy)NSString *energyValue;

@property (nonatomic, copy)NSString *dateMsg;

@property (nonatomic, copy)NSString *timeMsg;

@property (nonatomic, assign)NSInteger segmentIndex;

@end

@interface MKLFXEnergyTableHeaderView : UIView

@property (nonatomic, strong)MKLFXEnergyTableHeaderViewModel *dataModel;

@end

NS_ASSUME_NONNULL_END
