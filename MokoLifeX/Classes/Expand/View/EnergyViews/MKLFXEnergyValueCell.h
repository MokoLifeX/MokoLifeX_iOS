//
//  MKLFXEnergyValueCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXEnergyValueCellModel : NSObject

@property (nonatomic, copy)NSString *timeValue;

@property (nonatomic, copy)NSString *dateValue;

@property (nonatomic, copy)NSString *energyValue;

@end

@interface MKLFXEnergyValueCell : MKBaseCell

@property (nonatomic, strong)MKLFXEnergyValueCellModel *dataModel;

+ (MKLFXEnergyValueCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
