//
//  MKLFXCDOTADataModel.h
//  MokoLifeX_Example
//
//  Created by aa on 2021/12/4.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Master Firmware
@interface MKLFXCDOTAMasterFirmwareModel : NSObject

@property (nonatomic, copy)NSString *host;

@property (nonatomic, copy)NSString *port;

@property (nonatomic, copy)NSString *filePath;

@end


@interface MKLFXCDOTACACertificateModel : NSObject

@property (nonatomic, copy)NSString *host;

@property (nonatomic, copy)NSString *port;

@property (nonatomic, copy)NSString *filePath;

@end


@interface MKLFXCDOTASelfSignedModel : NSObject

@property (nonatomic, copy)NSString *host;

@property (nonatomic, copy)NSString *port;

@property (nonatomic, copy)NSString *caFilePath;

@property (nonatomic, copy)NSString *clientKeyPath;

@property (nonatomic, copy)NSString *clientCertPath;

@end


@interface MKLFXCDOTADataModel : NSObject

/// 当前用户选择的OTA类型.   0:Master Firmware       1:CA certificate     2:Self signed server certificates
@property (nonatomic, assign)NSInteger type;

@property (nonatomic, strong, readonly)MKLFXCDOTAMasterFirmwareModel *masterModel;

@property (nonatomic, strong, readonly)MKLFXCDOTACACertificateModel *caFileModel;

@property (nonatomic, strong, readonly)MKLFXCDOTASelfSignedModel *signedModel;

- (NSString *)checkParams;

@end

NS_ASSUME_NONNULL_END
