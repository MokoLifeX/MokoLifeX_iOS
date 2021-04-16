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

@protocol MKMeasuredPowerLEDCellDelegate <NSObject>

- (void)measuredPowerLEDColorChanged:(NSString *)text row:(NSInteger)row;

@end

@interface MKMeasuredPowerLEDCell : UITableViewCell

@property (nonatomic, strong)MKMeasuredPowerLEDModel *dataModel;

@property (nonatomic, weak)id <MKMeasuredPowerLEDCellDelegate>delegate;

+ (MKMeasuredPowerLEDCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
