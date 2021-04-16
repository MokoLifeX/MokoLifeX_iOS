//
//  MKEnergyValueCell.h
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/15.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKEnergyValueCellModel;
@interface MKEnergyValueCell : MKBaseCell

@property (nonatomic, strong)MKEnergyValueCellModel *dataModel;

+ (MKEnergyValueCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
