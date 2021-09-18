//
//  MKLFXDeviceInfoController.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/7.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBaseController.h"

#import "MKLFXDeviceInfoPageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXDeviceInfoController : MKLFXBaseController

@property (nonatomic, strong)id <MKLFXDeviceInfoPageProtocol>protocol;

@end

NS_ASSUME_NONNULL_END
