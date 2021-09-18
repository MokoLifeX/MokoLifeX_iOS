//
//  MKLFXCLEDColorCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCLEDColorCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *placeholder;

@property (nonatomic, copy)NSString *textValue;

@property (nonatomic, assign)NSInteger index;

@end

@protocol MKLFXCLEDColorCellDelegate <NSObject>

- (void)lfxc_ledColorChanged:(NSString *)value index:(NSInteger)index;

@end

@interface MKLFXCLEDColorCell : MKBaseCell

@property (nonatomic, strong)MKLFXCLEDColorCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXCLEDColorCellDelegate>delegate;

+ (MKLFXCLEDColorCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
