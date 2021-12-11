//
//  MKLFXPowerOnStatusCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/9.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXPowerOnStatusCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, strong)UIImage *icon;

@end

@interface MKLFXPowerOnStatusCell : MKBaseCell

@property (nonatomic, strong)MKLFXPowerOnStatusCellModel *dataModel;

+ (MKLFXPowerOnStatusCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
