//
//  MKSlider.m
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKSlider.h"

#import "MKDeviceDefine.h"

@implementation MKSlider

- (instancetype)init{
    if (self = [super init]) {
        [self setThumbImage:[LOADICON(@"MKSlider",@"sliderThumbIcon.png") resizableImageWithCapInsets:UIEdgeInsetsZero]
                   forState:UIControlStateNormal];
        [self setThumbImage:[LOADICON(@"MKSlider",@"sliderThumbIcon.png") resizableImageWithCapInsets:UIEdgeInsetsZero]
                   forState:UIControlStateHighlighted];
        [self setMinimumTrackImage:[LOADICON(@"MKSlider",@"sliderMinimumTrackIcon.png") resizableImageWithCapInsets:UIEdgeInsetsZero]
                          forState:UIControlStateNormal];
        [self setMaximumTrackImage:[LOADICON(@"MKSlider",@"sliderMaximumTrackImage.png") resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateNormal];
    }
    return self;
}

@end
