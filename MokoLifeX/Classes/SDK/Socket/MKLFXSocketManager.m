//
//  MKLFXSocketManager.m
//  MokoLifeX_Example
//
//  Created by aa on 2021/8/19.
//  Copyright © 2021 aadyx2007@163.com. All rights reserved.
//

#import "MKLFXSocketManager.h"

#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#import "MKLFXSocketDefines.h"
#import "MKLFXSocketOperation.h"
#import "MKLFXSocketAdopter.h"
#import "MKLFXSocketOperationProtocol.h"

//设备默认的ip地址
NSString *const lfx_defaultHostIpAddress = @"192.168.4.1";
//设备默认的端口号
NSInteger const lfx_defaultPort = 8266;

static MKLFXSocketManager *manager = nil;
static dispatch_once_t onceToken;

@interface MKLFXSocketManager ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong)GCDAsyncSocket *socket;

@property (nonatomic, strong)dispatch_queue_t socketQueue;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@property (nonatomic, copy)void (^connectSucBlock)(void);

@property (nonatomic, copy)void (^connectFailedBlock)(NSError *error);

/**
 连接定时器，超过指定时间将会视为连接失败
 */
@property (nonatomic, strong)dispatch_source_t connectTimer;

/**
 连接超时标记
 */
@property (nonatomic, assign)BOOL connectTimeout;

@end

@implementation MKLFXSocketManager

- (instancetype)init {
    if (self = [super init]) {
        _socketQueue = dispatch_queue_create("com.moko.MKSocketManagerQueue", nil);
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_socketQueue];
    }
    return self;
}

+ (MKLFXSocketManager *)shared {
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [MKLFXSocketManager new];
        }
    });
    return manager;
}

+ (void)sharedDealloc {
    manager = nil;
    onceToken = 0;
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    if (self.connectTimeout) {
        return;
    }
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    MKSKBase_main_safe(^{
        if (self.connectSucBlock) {
            self.connectSucBlock();
        }
    });
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    if (!err) {
        return;
    }
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    [self.operationQueue cancelAllOperations];
    MKSKBase_main_safe(^{
        if (self.connectFailedBlock) {
            self.connectFailedBlock(err);
        }
    });
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //发送成功之后读取数值
    NSLog(@"发送数据成功");
    [self.socket readDataWithTimeout:2.f tag:tag];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKLFXSocketOperation <MKLFXSocketOperationProtocol>*operation in operations) {
            if (operation.executing) {
                [operation lfx_sendDataResult:NO tag:tag returnData:nil];
                break;
            }
        }
    }
    return 0.f;
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"HTTP Response:\n%@", httpResponse);
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKLFXSocketOperation <MKLFXSocketOperationProtocol>*operation in operations) {
            if (operation.executing) {
                [operation lfx_sendDataResult:YES
                                          tag:tag
                                   returnData:[MKLFXSocketAdopter dictionaryWithJsonString:httpResponse]];
                break;
            }
        }
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock
shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (MKLFXSocketOperation <MKLFXSocketOperationProtocol>*operation in operations) {
            if (operation.executing) {
                [operation lfx_sendDataResult:NO tag:tag returnData:nil];
                break;
            }
        }
    }
    return 0.f;
}

#pragma mark - public method
- (void)connectWithHost:(NSString *)host
                   port:(NSInteger)port
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    if (![MKLFXSocketAdopter isValidatIP:host] || port < 0 || port > 65535) {
        [self operationFailedBlockWithMsg:@"Params Error" failedBlock:failedBlock];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self connect:host port:port sucBlock:^{
        __strong typeof(self) sself = weakSelf;
        if (sucBlock) {
            sucBlock();
        }
        [sself clearConnectBlock];
    } failedBlock:^(NSError *error) {
        __strong typeof(self) sself = weakSelf;
        if (failedBlock) {
            failedBlock(error);
        }
        [sself clearConnectBlock];
    }];
}

- (void)disconnect {
    [self.socket disconnect];
}

- (void)addTaskWithTag:(long)tag
                  data:(NSString *)data
              sucBlock:(void (^)(id returnData))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!MKSKValidStr(data)) {
        [self operationFailedBlockWithMsg:@"The data sent to the device cannot be empty" failedBlock:failedBlock];
        return;
    }
    if (!self.socket.isConnected) {
        [self operationFailedBlockWithMsg:@"The current connection device is in disconnect" failedBlock:failedBlock];
        return;
    }
    __weak typeof(self) weakSelf = self;
    MKLFXSocketOperation *operation = [[MKLFXSocketOperation alloc] initOperationWithTag:tag
                                                                           completeBlock:^(NSError * _Nullable error, id  _Nullable returnData) {
        __strong typeof(self) sself = weakSelf;
        if (error) {
            MKSKBase_main_safe(^{
                if (failedBlock) {
                    failedBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [sself operationFailedBlockWithMsg:@"Request data error" failedBlock:failedBlock];
            return ;
        }
        MKSKBase_main_safe(^{
            if (sucBlock) {
                sucBlock(returnData);
            }
        });
    }];
    
    [self.operationQueue addOperation:operation];
    NSData *commandData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:commandData withTimeout:2.f tag:tag];
}

- (void)readDeviceInfoWithSucBlock:(void (^)(id returnData))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    [self addTaskWithTag:20210826010
                    data:[MKLFXSocketAdopter convertToJsonData:@{@"header":@(4001)}]
                sucBlock:sucBlock
             failedBlock:failedBlock];
}

#pragma mark - connect private method
- (void)connect:(NSString *)host
           port:(NSInteger)port
       sucBlock:(void (^)(void))sucBlock
    failedBlock:(void (^)(NSError *error))failedBlock {
    self.connectSucBlock = nil;
    self.connectSucBlock = sucBlock;
    self.connectFailedBlock = nil;
    self.connectFailedBlock = failedBlock;
    if (self.socket.isConnected) {
        [self.socket disconnect];
    }
    self.connectTimeout = NO;
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    [self initConnectTimer];
    NSError *error = nil;
    BOOL pass = [self.socket connectToHost:host onPort:port withTimeout:15.f error:&error];
    if (!pass) {
        MKSKBase_main_safe(^{
            if (failedBlock) {
                failedBlock(error);
            }
        });
    }
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailedBlock) {
        self.connectFailedBlock = nil;
    }
}

- (void)initConnectTimer{
    dispatch_queue_t connectQueue = dispatch_queue_create("mokoConnectSocketQueue", DISPATCH_QUEUE_CONCURRENT);
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,connectQueue);
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 15.f * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 15.f * NSEC_PER_SEC;
    dispatch_source_set_timer(self.connectTimer, start, interval, 0);
    __weak __typeof(&*self)weakSelf = self;
    dispatch_source_set_event_handler(self.connectTimer, ^{
        __strong typeof(self) sself = weakSelf;
        sself.connectTimeout = YES;
        dispatch_cancel(sself.connectTimer);
        [sself.socket disconnect];
        [self operationFailedBlockWithMsg:@"Connect Failed" failedBlock:sself.connectFailedBlock];
    });
    dispatch_resume(self.connectTimer);
}

- (void)operationFailedBlockWithMsg:(NSString *)message failedBlock:(void (^)(NSError *error))failedBlock {
    NSError *error = [[NSError alloc] initWithDomain:@"com.moko.MKSocketManager"
                                                code:-999
                                            userInfo:@{@"errorInfo":message}];
    MKSKBase_main_safe(^{
        if (failedBlock) {
            failedBlock(error);
        }
    });
}

#pragma mark - getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
