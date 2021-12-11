//
//  MKLFXCColorSettingModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/15.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXCMQTTInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCColorSettingModel : NSObject

@property (nonatomic, assign)mk_lfxc_ledColorType colorType;

@property (nonatomic, assign)mk_lfxc_productModel productModel;

@property (nonatomic, assign)BOOL productModelSuccess;

@property (nonatomic, assign)BOOL colorDataSuccess;

@end

NS_ASSUME_NONNULL_END
