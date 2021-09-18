//
//  MKLFXCMQTTSettingForDeviceCell.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/9/12.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <MKBaseModuleLibrary/MKBaseCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXCMQTTSettingForDeviceCellModel : NSObject

@property (nonatomic, copy)NSString *msg;

@property (nonatomic, copy)NSString *rightMsg;

- (CGFloat)fetchCellHeight;

@end

@interface MKLFXCMQTTSettingForDeviceCell : MKBaseCell

@property (nonatomic, strong)MKLFXCMQTTSettingForDeviceCellModel *dataModel;

+ (MKLFXCMQTTSettingForDeviceCell *)initCellWithTableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_END
