//
//  MKNormalTextCell.h
//  mokoLibrary_Example
//
//  Created by aa on 2020/12/16.
//  Copyright © 2020 Chengang. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKNormalTextCellModel : NSObject

/// 左侧msg
@property (nonatomic, copy)NSString *leftMsg;

/// 右侧msg
@property (nonatomic, copy)NSString *rightMsg;

/// 是否显示右侧的箭头
@property (nonatomic, assign)BOOL showRightIcon;

/// 点击cell如果push一个controller，则填写这个controller的Class
@property (nonatomic, assign)Class functionPage;

/// 点击cell之后触发的方法，选填
@property (nonatomic, copy)NSString *methodName;

@end

@interface MKNormalTextCell : MKBaseCell

+ (MKNormalTextCell *)initCellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong)MKNormalTextCellModel *dataModel;

@end

NS_ASSUME_NONNULL_END
