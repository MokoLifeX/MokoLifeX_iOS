//
//  MKLFXSocketOperationProtocol.h
//  MokoLifeX
//
//  Created by aa on 2021/8/26.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXSocketOperationProtocol <NSObject>

/// socket发送数据之后得到的反馈
/// @param success 是否发送成功
/// @param tag 通信tag
/// @param returnData 设备返回的数据
- (void)lfx_sendDataResult:(BOOL)success
                       tag:(long)tag
                returnData:(NSDictionary *)returnData;


@end

NS_ASSUME_NONNULL_END
