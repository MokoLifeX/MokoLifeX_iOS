//
//  MKLFXAOVMDHeaderView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/21.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXAOVMDHeaderViewDelegate <NSObject>

/// 用户改变了输入框的值
/// @param text 当前输入框的值
/// @param index 参考如下:
/*
 index的参考值:
 0:host
 1:port
 2:userName
 3:password
 4:keep alive
 5:clientID
 6:deviceID
 */
- (void)lfxa_ovmdHeaderViewTextFieldValueChanged:(NSString *)text index:(NSInteger)index;

//用户改变了clean session值
- (void)lfxa_ovmdHeaderViewCleanSessionChanged:(BOOL)isOn;

//用户改变了qos值
- (void)lfxa_ovmdHeaderViewQosChanged:(NSInteger)qos;

/// 用户选择了connectMode
/// @param connectMode 0(TCP)/1(One-way SSL)/2(Two-way SSL)
- (void)lfxa_ovmdHeaderViewConnectModeChanged:(NSInteger)connectMode;

@end

@class MKLFXAOVMDHeaderViewModel;
@interface MKLFXAOVMDHeaderView : UIView

@property (nonatomic, strong)MKLFXAOVMDHeaderViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXAOVMDHeaderViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
