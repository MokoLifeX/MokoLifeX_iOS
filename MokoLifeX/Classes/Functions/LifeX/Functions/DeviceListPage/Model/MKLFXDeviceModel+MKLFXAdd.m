//
//  MKLFXDeviceModel+MKLFXAdd.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/1.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXDeviceModel+MKLFXAdd.h"

#import <objc/runtime.h>

static const char *lfx_overloadKey = "lfx_overloadKey";

@implementation MKLFXDeviceModel (MKLFXAdd)

- (void)setIsOverload:(BOOL)isOverload {
    objc_setAssociatedObject(self, &lfx_overloadKey, @(isOverload), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isOverload {
    return [objc_getAssociatedObject(self, &lfx_overloadKey) boolValue];
}

@end
