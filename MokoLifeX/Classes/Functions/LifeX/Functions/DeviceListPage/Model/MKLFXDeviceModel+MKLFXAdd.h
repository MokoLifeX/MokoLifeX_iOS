//
//  MKLFXDeviceModel+MKLFXAdd.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/1.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXDeviceModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXDeviceModel (MKLFXAdd)

/// MK115是否处于过载状态
@property (nonatomic, assign)BOOL isOverload;

@end

NS_ASSUME_NONNULL_END
