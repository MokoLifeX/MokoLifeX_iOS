//
//  MKEPParamsSettingController.h
//  MokoLifeX
//
//  Created by aa on 2020/6/17.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, mk_epParamsType) {
    mk_epParamsType_overload,
    mk_epParamsType_powerReportPeriod,
    mk_epParamsType_energyReportPeriod,
    mk_epParamsType_energyInterval,
};

@interface MKEPParamsSettingController : MKBaseViewController

@property (nonatomic, assign)mk_epParamsType configType;

@end

NS_ASSUME_NONNULL_END
