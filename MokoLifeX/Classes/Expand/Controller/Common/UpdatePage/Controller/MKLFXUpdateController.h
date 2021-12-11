//
//  MKLFXUpdateController.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBaseController.h"

#import "MKLFXUpdatePageProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXUpdateController : MKLFXBaseController

@property (nonatomic, strong)id <MKLFXUpdatePageProtocol>protocol;

@end

NS_ASSUME_NONNULL_END
