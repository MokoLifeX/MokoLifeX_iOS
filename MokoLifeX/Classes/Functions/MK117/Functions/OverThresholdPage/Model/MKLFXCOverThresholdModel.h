//
//  MKLFXCOverThresholdModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/11.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXCMQTTInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCOverThresholdModel : NSObject

@property (nonatomic, assign)BOOL isOn;

@property (nonatomic, copy)NSString *valueThreshold;

@property (nonatomic, copy)NSString *timeThreshold;

@property (nonatomic, assign)mk_lfxc_productModel productModel;

@property (nonatomic, assign)BOOL readOverValueSuccess;

@property (nonatomic, assign)BOOL readProductModelSuccess;

- (BOOL)checkParams;

@end

NS_ASSUME_NONNULL_END
