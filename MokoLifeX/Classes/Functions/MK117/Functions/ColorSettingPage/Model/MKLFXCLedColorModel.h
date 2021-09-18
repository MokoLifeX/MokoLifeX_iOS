//
//  MKLFXCLedColorModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXCMQTTInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCLedColorModel : NSObject<mk_lfxc_ledColorConfigProtocol>

/*
 Blue.
 European and French specifications:1 <=  b_color <= 4411.
 American specifications:1 <=  b_color <= 2155.
 British specifications:1 <=  b_color <= 3584.
 */
@property (nonatomic, assign)NSInteger b_color;

/*
 Green.
 European and French specifications:b_color < g_color <= 4412.
 American specifications:b_color < g_color <= 2156.
 British specifications:b_color < g_color <= 3584.
 */
@property (nonatomic, assign)NSInteger g_color;

/*
 Yellow.
 European and French specifications:g_color < y_color <= 4413.
 American specifications:g_color < y_color <= 2157.
 British specifications:g_color < y_color <= 3585.
 */
@property (nonatomic, assign)NSInteger y_color;

/*
 Orange.
 European and French specifications:y_color < o_color <= 4414.
 American specifications:y_color < o_color <= 2158.
 British specifications:y_color < o_color <= 3586.
 */
@property (nonatomic, assign)NSInteger o_color;

/*
 Red.
 European and French specifications:o_color < r_color <= 4415.
 American specifications:o_color < r_color <= 2159.
 British specifications:o_color < r_color <= 3587.
 */
@property (nonatomic, assign)NSInteger r_color;

/*
 Purple.
 European and French specifications:r_color < p_color <=  4416.
 American specifications:r_color < p_color <=  2160.
 British specifications:r_color < p_color <=  3588.
 */
@property (nonatomic, assign)NSInteger p_color;

@end

NS_ASSUME_NONNULL_END
