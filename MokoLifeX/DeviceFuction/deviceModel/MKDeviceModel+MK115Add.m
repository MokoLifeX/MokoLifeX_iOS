//
//  MKDeviceModel+MK115Add.m
//  MokoLifeX
//
//  Created by aa on 2020/8/21.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKDeviceModel+MK115Add.h"
#import <objc/runtime.h>

static const char *isOverloadKey = "isOverloadKey";

@implementation MKDeviceModel (MK115Add)

- (void)setIsOverload:(BOOL)isOverload {
    objc_setAssociatedObject(self, &isOverloadKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &isOverloadKey, @(isOverload), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isOverload {
    return [objc_getAssociatedObject(self, &isOverloadKey) boolValue];
}

@end
