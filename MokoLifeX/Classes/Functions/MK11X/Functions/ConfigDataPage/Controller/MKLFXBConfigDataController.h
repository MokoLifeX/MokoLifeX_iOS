//
//  MKLFXBConfigDataController.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXBaseController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_lfxb_configDataPageType) {
    mk_lfxb_configDataPageType_overloadValue,
    mk_lfxb_configDataPageType_powerReport,
    mk_lfxb_configDataPageType_energyStorage,
};

@interface MKLFXBConfigDataController : MKLFXBaseController

@property (nonatomic, assign)mk_lfxb_configDataPageType pageType;

@end

NS_ASSUME_NONNULL_END
