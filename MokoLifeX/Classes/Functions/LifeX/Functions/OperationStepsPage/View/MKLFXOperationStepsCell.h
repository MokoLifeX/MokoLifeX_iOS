//
//  MKLFXOperationStepsCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/20.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXOperationStepsCellModel : NSObject

@property (nonatomic, copy)NSString *titleMsg;

@property (nonatomic, copy)NSString *noteMsg;

@property (nonatomic, copy)NSString *leftIconName;

@property (nonatomic, copy)NSString *rightIconName;

@end

@interface MKLFXOperationStepsCell : MKBaseCell

@property (nonatomic, strong)MKLFXOperationStepsCellModel *dataModel;

+ (MKLFXOperationStepsCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
