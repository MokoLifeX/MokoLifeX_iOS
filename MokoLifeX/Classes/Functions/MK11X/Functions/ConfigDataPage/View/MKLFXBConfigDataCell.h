//
//  MKLFXBConfigDataCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBConfigDataCellModel : NSObject

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, assign)NSInteger maxLen;

@property (nonatomic, copy)NSString *placeholder;

@end

@protocol MKLFXBConfigDataCellDelegate <NSObject>

- (void)lfxb_configDataValueChanged:(NSString *)text index:(NSInteger)index;

@end

@interface MKLFXBConfigDataCell : MKBaseCell

@property (nonatomic, strong)MKLFXBConfigDataCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXBConfigDataCellDelegate>delegate;

+ (MKLFXBConfigDataCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
