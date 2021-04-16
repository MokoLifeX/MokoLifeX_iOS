//
//  MKSettingPageCell.h
//  MKBLEMokoLife
//
//  Created by aa on 2020/5/13.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKSettingPageCellModel;
@interface MKSettingPageCell : MKBaseCell

@property (nonatomic, strong)MKSettingPageCellModel *dataModel;

+ (MKSettingPageCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
