//
//  MKUpdateFirmwareTypeCell.h
//  MokoLifeX
//
//  Created by aa on 2019/8/8.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, updateFirmwareCellType) {
    update_firmware,
    update_caCertification,
    update_clientCertification,
    update_clientKey,
};

@interface MKUpdateFirmwareTypeCell : MKBaseCell

+ (MKUpdateFirmwareTypeCell *)initCellWithTableView:(UITableView *)tableView;

- (updateFirmwareCellType)currentFileType;

@end

NS_ASSUME_NONNULL_END
