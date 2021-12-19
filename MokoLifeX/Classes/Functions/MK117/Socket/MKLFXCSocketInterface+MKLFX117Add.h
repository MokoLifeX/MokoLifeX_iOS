//
//  MKLFXCSocketInterface+MKLFX117Add.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/18.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXCSocketInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCSocketInterface (MKLFX117Add)

/// 配置时区(MK117)
/// @param timeZone -24~24(单位:0.5)
/// @param sucBlock 成功回调
/// @param failedBlock 失败回调
- (void)lfxc_configTimeZone:(NSInteger)timeZone
                   sucBlock:(void (^)(id returnData))sucBlock
                failedBlock:(void (^)(NSError *error))failedBlock;

@end

NS_ASSUME_NONNULL_END
