//
//  MKLFXBLedColorModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXBMQTTInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBLedColorModel : NSObject<mk_lfxb_ledColorConfigProtocol>

/// Blue..
/// 1 <=  b_color <= 3790.
@property (nonatomic, assign)NSInteger b_color;

/// Green
/// b_color < g_color <= 3791.
@property (nonatomic, assign)NSInteger g_color;

/// Yellow
/// g_color < y_color <= 3792.
@property (nonatomic, assign)NSInteger y_color;

/// Orange
/// y_color < o_color <= 3793.
@property (nonatomic, assign)NSInteger o_color;

/// Red
/// o_color < r_color <= 3794.
@property (nonatomic, assign)NSInteger r_color;

/// Purple
/// r_color < p_color <=  3795.
@property (nonatomic, assign)NSInteger p_color;

@end

NS_ASSUME_NONNULL_END
