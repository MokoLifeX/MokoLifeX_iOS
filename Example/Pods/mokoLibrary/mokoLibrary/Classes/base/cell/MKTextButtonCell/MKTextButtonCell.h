//
//  MKTextButtonCell.h
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKBaseCell.h"

/*
    右侧按钮点击事件会抛出MKTextFieldNeedHiddenKeyboard通知
 [[NSNotificationCenter defaultCenter] postNotificationName:@"MKTextFieldNeedHiddenKeyboard" object:nil];
 */

NS_ASSUME_NONNULL_BEGIN

@interface MKTextButtonCellModel : NSObject

/// 左侧显示的msg
@property (nonatomic, copy)NSString *msg;

/// 点击右侧按钮时显示的pickView列表数据源
@property (nonatomic, strong)NSArray *dataList;

/// 当前cell所在的index
@property (nonatomic, assign)NSInteger index;

/// 当前数据源dataList选中的index,右侧按钮会显示dataList[dataListIndex]
@property (nonatomic, assign)NSInteger dataListIndex;

/// 右侧按钮的背景颜色
@property (nonatomic, strong)UIColor *buttonBackColor;

/// 右侧按钮的title颜色
@property (nonatomic, strong)UIColor *buttonTitleColor;

@end

@protocol MKTextButtonCellDelegate <NSObject>

/// 右侧按钮点击触发的回调事件
/// @param index 当前cell所在的index
/// @param dataListIndex 点击按钮选中的dataList里面的index
/// @param value dataList[dataListIndex]
- (void)mk_loraTextButtonCellSelected:(NSInteger)index
                        dataListIndex:(NSInteger)dataListIndex
                                value:(NSString *)value;

@end

@interface MKTextButtonCell : MKBaseCell

@property (nonatomic, strong)MKTextButtonCellModel *dataModel;

@property (nonatomic, weak)id <MKTextButtonCellDelegate>delegate;

+ (MKTextButtonCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
