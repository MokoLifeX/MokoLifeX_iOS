//
//  MKLFXUpdateModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXUpdateModel : NSObject

/// 0:Firmware     1:CA certification      2:Client certification        3:Client key
@property (nonatomic, assign)NSInteger type;

@property (nonatomic, copy)NSString *host;

@property (nonatomic, copy)NSString *port;

@property (nonatomic, copy)NSString *catalogue;

@end

NS_ASSUME_NONNULL_END
