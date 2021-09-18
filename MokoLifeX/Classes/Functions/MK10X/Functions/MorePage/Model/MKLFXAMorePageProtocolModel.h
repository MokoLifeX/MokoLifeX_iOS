//
//  MKLFXAMorePageProtocolModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/17.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MKLFXUpdatePageProtocol.h"
#import "MKLFXDeviceInfoPageProtocol.h"
#import "MKLFXPowerOnStatusProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXAUpdateDataModel : NSObject<MKLFXUpdatePageProtocol>

@end

@interface MKLFXADeviceInfoDataModel : NSObject<MKLFXDeviceInfoPageProtocol>

@end

@interface MKLFXAPowerOnStatusModel : NSObject<MKLFXPowerOnStatusProtocol>

@end

NS_ASSUME_NONNULL_END
