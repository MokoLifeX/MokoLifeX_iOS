//
//  MKLFXCEnergyReportCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCEnergyReportCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, copy)NSString *textValue;

@property (nonatomic, copy)NSString *noteMsg;

/// 输入框最大输入位数
@property (nonatomic, assign)NSInteger maxLen;

@end

@protocol MKLFXCEnergyReportCellDelegate <NSObject>

- (void)lfxc_textFieldValueChanged:(NSString *)text index:(NSInteger)index;

@end

@interface MKLFXCEnergyReportCell : MKBaseCell

@property (nonatomic, strong)MKLFXCEnergyReportCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXCEnergyReportCellDelegate>delegate;

+ (MKLFXCEnergyReportCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
