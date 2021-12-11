//
//  MKLFXCOverThresholdController.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/11.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCBaseController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_lfxc_overThresholdType) {
    mk_lfxc_overThresholdType_load,
    mk_lfxc_overThresholdType_voltage,
    mk_lfxc_overThresholdType_current,
};

@interface MKLFXCOverThresholdController : MKLFXCBaseController

@property (nonatomic, assign)mk_lfxc_overThresholdType pageType;

@end

NS_ASSUME_NONNULL_END
