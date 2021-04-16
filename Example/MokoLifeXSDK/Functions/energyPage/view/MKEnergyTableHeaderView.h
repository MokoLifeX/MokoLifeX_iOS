//
//  MKEnergyTableHeaderView.h
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKEnergyTableHeaderViewModel : NSObject

@property (nonatomic, copy)NSString *energyValue;

@property (nonatomic, copy)NSString *dateMsg;

@property (nonatomic, copy)NSString *timeMsg;

@end

@interface MKEnergyTableHeaderView : UIView

@property (nonatomic, strong)MKEnergyTableHeaderViewModel *viewModel;

@end

NS_ASSUME_NONNULL_END
