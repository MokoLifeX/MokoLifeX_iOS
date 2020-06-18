//
//  MKMeasuredPowerLEDColorModel.h
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKMeasuredPowerLEDColorModel : NSObject<mk_ledColorConfigProtocol>

@property (nonatomic, assign)NSInteger b_color;

@property (nonatomic, assign)NSInteger g_color;

@property (nonatomic, assign)NSInteger y_color;

@property (nonatomic, assign)NSInteger o_color;

@property (nonatomic, assign)NSInteger r_color;

@property (nonatomic, assign)NSInteger p_color;

@end

NS_ASSUME_NONNULL_END
