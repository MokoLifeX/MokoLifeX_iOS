//
//  MKLFXCSystemTimeCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/10.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCSystemTimeCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *buttonTitle;

@end

@protocol MKLFXCSystemTimeCellDelegate <NSObject>

- (void)lfxc_syncTimeFromPhone;

@end

@interface MKLFXCSystemTimeCell : MKBaseCell

@property (nonatomic, strong)MKLFXCSystemTimeCellModel *dataModel;

@property (nonatomic, weak)id <MKLFXCSystemTimeCellDelegate>delegate;

+ (MKLFXCSystemTimeCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
