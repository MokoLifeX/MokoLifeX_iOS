//
//  MKLFXDeviceListCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@class MKLFXDeviceModel;

@protocol MKLFXDeviceListCellDelegate <NSObject>

/// 用户点击开关按钮
/// @param deviceModel deviceModel
- (void)lfx_deviceStateChanged:(MKLFXDeviceModel *)deviceModel;

/**
 删除
 
 @param index 所在index
 */
- (void)lfx_cellDeleteButtonPressed:(NSInteger)index;

@end

@interface MKLFXDeviceListCell : MKBaseCell

@property (nonatomic, strong)MKLFXDeviceModel *dataModel;

@property (nonatomic, weak)id <MKLFXDeviceListCellDelegate>delegate;

+ (MKLFXDeviceListCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
