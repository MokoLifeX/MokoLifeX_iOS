//
//  MKLFXCOverThresholdCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/11.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCOverThresholdCellModel : NSObject

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *textValue;

/// 输入框最大字符个数
@property (nonatomic, assign)NSInteger maxLen;

@property (nonatomic, copy)NSString *placeholder;

/// 是否有小数点，键盘不一样
@property (nonatomic, assign)BOOL floatType;

@end

@protocol MKLFXCOverThresholdCellDelegate <NSObject>

- (void)lfxc_textValueChanged:(NSString *)text index:(NSInteger)index;

@end

@interface MKLFXCOverThresholdCell : MKBaseCell

@property (nonatomic, strong)MKLFXCOverThresholdCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXCOverThresholdCellDelegate>delegate;

+ (MKLFXCOverThresholdCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
