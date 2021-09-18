//
//  MKLFXAOVMDFileCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/21.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXAOVMDFileCellModel : NSObject

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *certName;

@end

@protocol MKLFXAOVMDFileCellDelegate <NSObject>

- (void)lfxa_certFileButtonPressed:(NSInteger)index;

@end

@interface MKLFXAOVMDFileCell : MKBaseCell

@property (nonatomic, strong)MKLFXAOVMDFileCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXAOVMDFileCellDelegate>delegate;

+ (MKLFXAOVMDFileCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
