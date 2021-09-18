//
//  MKLFXBSettingsPageCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/3.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBSettingsPageCellModel : NSObject

@property (nonatomic, copy)NSString *leftMsg;

@property (nonatomic, copy)NSString *rightMsg;

@end

@interface MKLFXBSettingsPageCell : MKBaseCell

@property (nonatomic, strong)MKLFXBSettingsPageCellModel *dataModel;

+ (MKLFXBSettingsPageCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
