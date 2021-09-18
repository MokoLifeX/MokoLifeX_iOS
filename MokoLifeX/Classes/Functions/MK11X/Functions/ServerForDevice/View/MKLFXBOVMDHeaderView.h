//
//  MKLFXBOVMDHeaderView.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MKLFXBOVMDHeaderViewDelegate <NSObject>

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
- (void)lfxb_ovmdHeaderViewTextFieldValueChanged:(NSString *)text index:(NSInteger)index;

//用户改变了clean session值
- (void)lfxb_ovmdHeaderViewCleanSessionChanged:(BOOL)isOn;

//用户改变了qos值
- (void)lfxb_ovmdHeaderViewQosChanged:(NSInteger)qos;

/// 用户选择了connectMode
/// @param connectMode 0(TCP)/1(One-way SSL)/2(Two-way SSL)
- (void)lfxb_ovmdHeaderViewConnectModeChanged:(NSInteger)connectMode;

@end

@class MKLFXBOVMDHeaderViewModel;
@interface MKLFXBOVMDHeaderView : UIView

@property (nonatomic, strong)MKLFXBOVMDHeaderViewModel *dataModel;

@property (nonatomic, weak)id <MKLFXBOVMDHeaderViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
