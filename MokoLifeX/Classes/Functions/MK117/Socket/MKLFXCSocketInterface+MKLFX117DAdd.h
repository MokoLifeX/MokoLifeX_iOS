//
//  MKLFXCSocketInterface+MKLFX117DAdd.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSocketInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCSocketInterface (MKLFX117DAdd)

/// 读取当前设备频段
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxc_readChannelWithSucBlock:(void (^)(id returnData))sucBlock
                         failedBlock:(void (^)(NSError *error))failedBlock;

/// 配置时区(MK117D)
/// @param timeZone -24~28(单位:0.5)
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxc_config117DTimeZone:(NSInteger)timeZone
                       sucBlock:(void (^)(id returnData))sucBlock
                    failedBlock:(void (^)(NSError *error))failedBlock;

/// 修改信道区域参数
/// @param channel 信道，具体参照下面
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
/*
 信道范围：0~ 21，默认9。
 0: Argentina,Mexico
 1: Australia,New Zealand
 2: Bahrain、Egypt、Israel、India
 3: Bolivia、Chile、China、El Salvador
 4: Canada
 5: Europe
 6: Indonesia
 7: Japan
 8: Jordan
 9: Korea、US
 10: Latin America-1
 11: Latin America-2
 12: Latin America-3
 13: Lebanon
 14: Malaysia
 15: Qatar
 16: Russia
 17: Singapore
 18: Taiwan
 19: Tunisia
 20: Venezuela
 21: Worldwide (全球)
 */
- (void)lfxc_configChannel:(NSInteger)channel
                  sucBlock:(void (^)(id returnData))sucBlock
               failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
