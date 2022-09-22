//
//  MKLFXAboutCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2022/9/22.
//  Copyright © 2022 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXAboutCellModel : NSObject

@property (nonatomic, copy)NSString *typeMessage;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, copy)NSString *iconName;

@property (nonatomic, assign)BOOL canAdit;

@end

@interface MKLFXAboutCell : MKBaseCell

@property (nonatomic, strong)MKLFXAboutCellModel *dataModel;

+ (MKLFXAboutCell *)initCellWithTableView:(UITableView *)table;

@end

NS_ASSUME_NONNULL_END
