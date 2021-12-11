//
//  MKLFXBLEDColorCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBLEDColorCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *placeholder;

@property (nonatomic, copy)NSString *textValue;

@property (nonatomic, assign)NSInteger index;

@end

@protocol MKLFXBLEDColorCellDelegate <NSObject>

- (void)lfxb_ledColorChanged:(NSString *)value index:(NSInteger)index;

@end

@interface MKLFXBLEDColorCell : MKBaseCell

@property (nonatomic, strong)MKLFXBLEDColorCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXBLEDColorCellDelegate>delegate;

+ (MKLFXBLEDColorCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
