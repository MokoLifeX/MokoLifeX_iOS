
/*
 对应1124,当插座从服务器接收到修改网络配置参数指令（2126），插座会主动上报网络配置参数修改结果（指令错误返回0，证书下载失败返回0）。
 */
static NSString *const MKLFXCReceiveModifyMQTTConfigNotification = @"MKLFXCReceiveModifyMQTTConfigNotification";

/*
 对应2127,当插座从服务器接收到修改网络配置参数指令（2127），插座会应答.
 */
static NSString *const MKLFXCReceiveReconnectNetworkMQTTConfigNotification = @"MKLFXCReceiveReconnectNetworkMQTTConfigNotification";

/*
 设备OTA结果
 */
static NSString *const MKLFXCReceiveOTAResultNotification = @"MKLFXCReceiveOTAResultNotification";
