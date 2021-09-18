//
//  MKLFXAOVMDHeaderViewModel.h
//  MokoLifeX
//
//  Created by aa on 2021/8/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKLFXAOVMDHeaderViewModel : NSObject

/// 1~64 Characters
@property (nonatomic, copy)NSString *host;

/// 0~65535
@property (nonatomic, copy)NSString *port;

@property (nonatomic, assign)BOOL cleanSession;

/// 0-256 Characters
@property (nonatomic, copy)NSString *userName;

/// 0-256 Characters
@property (nonatomic, copy)NSString *password;

/// 0、1、2
@property (nonatomic, assign)NSInteger qos;

/// 10s~120s
@property (nonatomic, copy)NSString *keepAlive;

/// 1-64 Characters
@property (nonatomic, copy)NSString *clientID;

/// /// 1-64 Characters
@property (nonatomic, copy)NSString *deviceID;

/// 0:tcp,1:one-way SSL,2:two-way SSL
@property (nonatomic, assign)NSInteger connectMode;

/// 校验参数，如果不为空则返回对应的参数错误，为空则表明参数正确
- (NSString *)checkParams;

@end

NS_ASSUME_NONNULL_END
