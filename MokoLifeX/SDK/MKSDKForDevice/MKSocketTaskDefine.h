
/*
 命令ID
 */
typedef NS_ENUM(NSInteger, MKSocketOperationID){
    socketUnknowOperation,                           //初始状态
    socketReadDeviceInformationOperation,            //读取设备信息
    socketConfigMQTTServerOperation,                 //配置mqtt服务器信息
    socketConfigWifiOperation,                       //配置plug要连接的wifi
    socketConfigTopicOperation,                      //配置MQTT通信的主题
    socketConfigEquipmentElectricalDefaultStateOperation,//配置设备上电默认状态
    socketConfigDeviceCertOperation,                //配置设备证书
    socketConfigDeviceMQTTIDOperation,              //配置设备的MQTT通信唯一标识符
};

@protocol MKSocketOperationProtocol <NSObject>

- (void)sendDataToPlugSuccess:(BOOL)success operationID:(MKSocketOperationID)operationID returnData:(NSDictionary *)returnData;

@end

