//
//  MKSocketTaskOperation.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/6.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKSocketTaskDefine.h"

/**
 任务完成回调
 
 @param error 是否产生了超时错误
 @param operationID 当前任务ID
 @param returnData 返回的数据
 */
typedef void(^communicationCompleteBlock)(NSError *error, MKSocketOperationID operationID, id returnData);
@interface MKSocketTaskOperation : NSOperation<MKSocketOperationProtocol>

/**
 init task
 
 @param operationID Current Task ID
 @param completeBlock Complete callback
 @return operation
 */
- (instancetype)initOperationWithID:(MKSocketOperationID)operationID
                      completeBlock:(communicationCompleteBlock)completeBlock;

@end
