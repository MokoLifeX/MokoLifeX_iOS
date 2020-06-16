//
//  MKMeasuredPowerLEDCell.h
//  MokoLifeX
//
//  Created by aa on 2020/6/16.
//  Copyright © 2020 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MKMeasuredPowerLEDModel;
@interface MKMeasuredPowerLEDCell : UITableViewCell

@property (nonatomic, strong)MKMeasuredPowerLEDModel *dataModel;

+ (MKMeasuredPowerLEDCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
