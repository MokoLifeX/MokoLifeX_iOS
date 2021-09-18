//
//  MKLFXBOVMDFileCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/24.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXBOVMDFileCellModel : NSObject

@property (nonatomic, assign)NSInteger index;

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *certName;

@end

@protocol MKLFXBOVMDFileCellDelegate <NSObject>

- (void)lfxb_certFileButtonPressed:(NSInteger)index;

@end

@interface MKLFXBOVMDFileCell : MKBaseCell

@property (nonatomic, strong)MKLFXBOVMDFileCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXBOVMDFileCellDelegate>delegate;

+ (MKLFXBOVMDFileCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
