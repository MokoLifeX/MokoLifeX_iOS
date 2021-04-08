//
//  MKTextFieldCell.h
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKBaseCell.h"

#import "UITextField+MKAdd.h"

/*
 如果想要键盘取消第一响应者，则需要发出MKTextFieldNeedHiddenKeyboard通知即可
 [[NSNotificationCenter defaultCenter] postNotificationName:@"MKTextFieldNeedHiddenKeyboard" object:nil];
 */

NS_ASSUME_NONNULL_BEGIN

@interface MKTextFieldCellModel : NSObject

/// 左侧msg
@property (nonatomic, copy)NSString *msg;

/// textField的占位符
@property (nonatomic, copy)NSString *textPlaceholder;

/// textField的最大输入长度
@property (nonatomic, assign)NSInteger maxLength;

/// 当前textField的输入类型
@property (nonatomic, assign)mk_CustomTextFieldType textFieldType;

/// 当前textField的值
@property (nonatomic, copy)NSString *textFieldValue;

/// 当前index，textField内容发生改变的时候，会连同textField值和该index一起回调，可以用来标示当前是哪个cell的回调事件
@property (nonatomic, assign)NSInteger index;

@property (nonatomic, assign)UITextFieldViewMode  clearButtonMode;

/// 最右侧的单位标签，如果该项为空则表示没有单位
@property (nonatomic, copy)NSString *unit;

/// textField边框颜色
@property (nonatomic, strong)UIColor *borderColor;

@end

@protocol MKTextFieldCellDelegate <NSObject>

/// textField内容发送改变时的回调事件
/// @param index 当前cell所在的index
/// @param value 当前textField的值
- (void)mk_deviceTextCellValueChanged:(NSInteger)index textValue:(NSString *)value;

@end

@interface MKTextFieldCell : MKBaseCell

@property (nonatomic, strong)MKTextFieldCellModel *dataModel;

@property (nonatomic, weak)id <MKTextFieldCellDelegate>delegate;

+ (MKTextFieldCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
