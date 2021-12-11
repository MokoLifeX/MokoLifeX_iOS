//
//  MKLFXSocketOperation.h
//  MokoLifeX
//
//  Created by aa on 2021/8/26.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXSocketOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXSocketOperation : NSOperation<MKLFXSocketOperationProtocol>

/**
 初始化通信线程
 
 @param tag 当前线程的任务tag
 @param completeBlock 数据通信完成回调
 @return operation
 */
- (instancetype)initOperationWithTag:(long)tag
                      completeBlock:(void (^)(NSError * _Nullable error, id _Nullable returnData))completeBlock;

@end

NS_ASSUME_NONNULL_END
