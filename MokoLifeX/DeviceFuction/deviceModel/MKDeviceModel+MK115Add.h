//
//  MKDeviceModel+MK115Add.h
//  MokoLifeX
//
//  Created by aa on 2020/8/21.
//  Copyright © 2020 MK. All rights reserved.
//


#import "MKDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceModel (MK115Add)

/// 是否处于过载状态
@property (nonatomic, assign)BOOL isOverload;

@end

NS_ASSUME_NONNULL_END
