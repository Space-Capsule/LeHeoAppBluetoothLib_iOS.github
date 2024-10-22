//
//  UnityBluetoothDataLib.m
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/2/17.
//

#import <Foundation/Foundation.h>
#import "UnityBluetoothDataLib.h"

extern "C"
{
    UnityBluetoothDataLib *_unityBluetoothDataLib = nil;

    void iosSetUnityGameObjectName(char *aUnityGameObjectName)
    {
        [GlobalConfig setUnityGameObjectName:[NSString stringWithCString:aUnityGameObjectName encoding:NSUTF8StringEncoding]];
    }

    void iosInitUnityBluetoothManager()
    {
        _unityBluetoothDataLib = [UnityBluetoothDataLib new];
        [_unityBluetoothDataLib initBluetoothManager];
    }

    void iosUnityBluetoothStartScan()
    {
        if (_unityBluetoothDataLib != nil)
        {
            [_unityBluetoothDataLib scanBluetoothPeripheral];
        }
    }

    void iosUnityBluetoothStopScan()
    {
        if (_unityBluetoothDataLib != nil)
        {
            [_unityBluetoothDataLib stopScan];
        }
    }

    void iosUnityBluetoothConnectPeripheral(char *aPeripheralIdentifier)
    {
        if (_unityBluetoothDataLib != nil)
        {
            [_unityBluetoothDataLib connectToDevice:[NSString stringWithFormat:@"%s", aPeripheralIdentifier]];
        }
    }

    void iosUnityBluetoothDisconnectAll()
    {
        if (_unityBluetoothDataLib != nil)
        {
            [_unityBluetoothDataLib disconnectAllBluetoothDevice];
        }
    }

    void iosSetCharacteristicNotificationCustom(char *aPeripheralIdentifier, char *aService, char *aCharacteristic)
    {
        if (_unityBluetoothDataLib != nil && aPeripheralIdentifier != nil && aService != nil && aCharacteristic != nil)
        {
            NSString *identifier = [NSString stringWithFormat:@"%s", aPeripheralIdentifier];
            NSString *service = [NSString stringWithFormat:@"%s", aService];
            NSString *characteristic = [NSString stringWithFormat:@"%s", aCharacteristic];
            
            // [_unityBluetoothDataLib setCharacteristicNotification:identifier service:service characteristic:characteristic];
            [_unityBluetoothDataLib setCharacteristicNotificationCustom:identifier service:service characteristic:characteristic];
        }
    }

    void iosSetCharacteristicNotification(char *aPeripheralIdentifier)
    {
        if (_unityBluetoothDataLib != nil && aPeripheralIdentifier != nil)
        {
            NSString *identifier = [NSString stringWithFormat:@"%s", aPeripheralIdentifier];
        
            // [_unityBluetoothDataLib setCharacteristicNotification:identifier service:service characteristic:characteristic];
            [_unityBluetoothDataLib setCharacteristicNotification:identifier];
        }
    }
}




#pragma mark - OC 的 code

@implementation UnityBluetoothDataLib

@synthesize _peripheralsDictionary;
@synthesize _data;

@synthesize _upperId;
@synthesize _downId;


- (void)initBluetoothManager
{
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss.SSS"];
    
    _centralManager = nil;
    
    _isInitializing = TRUE;
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
   
    NSLog(@"%@, init成功.", [GlobalConfig DebugTag]);
    UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "init Bluetooth Manager.");
}

- (void)scanBluetoothPeripheral
{
    if (_centralManager != nil)
    {

        if (_peripheralsDictionary == nil)
        {
            _peripheralsDictionary = [[NSMutableDictionary alloc] init];
        }
        else
        {
            [_peripheralsDictionary removeAllObjects];
        }
        
        if (_peripheralsList == nil)
        {
            _peripheralsList = [[NSMutableArray alloc] init];
        }
        else
        {
            [_peripheralsList removeAllObjects];
        }
        
//        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
        
        NSString *nowDateString = [_dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"%@ %@, 開始掃瞄!", nowDateString, [GlobalConfig DebugTag]);
    }
    else
    {
        NSLog(@"%@, CentralManager is nil!", [GlobalConfig DebugTag]);
    }
}

- (void)stopScan
{
    if (_centralManager != nil)
    {
        [_centralManager stopScan];

        UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "stopScan");
        
        if ([_peripheralsList count] < 1)
        {
            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "whenStopScan", "0");
        }
        
        NSString *nowDateString = [_dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"%@ %@, 停止掃瞄!", nowDateString, [GlobalConfig DebugTag]);
    }
    else
    {
        NSLog(@"%@, CentralManager is nil!", [GlobalConfig DebugTag]);
    }
}

- (void)connectToDevice:(NSString *)aIdentifier
{
    // NSLog(@"EthanLinBluetoothDataLib connect to %@", aIdentifier);
    if (_peripheralsDictionary != nil && aIdentifier != nil)
    {
        CBPeripheral *peripheral = [_peripheralsDictionary objectForKey:aIdentifier];
        if (peripheral != nil)
        {
            [_centralManager connectPeripheral:peripheral options:nil];
            NSString *nowDateString = [_dateFormatter stringFromDate:[NSDate date]];
            NSLog(@"%@ %@, connect to %@", nowDateString, [GlobalConfig DebugTag], aIdentifier);
        }
        else
        {
            NSLog(@"%@, error!!! peripheral is nil!", [GlobalConfig DebugTag]);
        }
    }
}

- (void)disconnectAllBluetoothDevice
{
    if (_peripheralsDictionary != nil && [_peripheralsDictionary count] > 0)
    {
        NSArray *keys = [_peripheralsDictionary allKeys];
        for (NSString *key in keys)
        {
            CBPeripheral *peripheral = [_peripheralsDictionary objectForKey:key];
            if (peripheral != nil)
            {
                [_centralManager cancelPeripheralConnection:peripheral];
            }
        }
        NSString *nowDateString = [_dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"%@ %@, 斷開所有連線", nowDateString, [GlobalConfig DebugTag]);
    }
}

- (void)setCharacteristicNotification:(NSString *)aIdentifier
{
    if (_peripheralsDictionary != nil && aIdentifier != nil)
    {
        CBPeripheral *peripheral = [_peripheralsDictionary objectForKey:aIdentifier];
        if (peripheral != nil)
        {
            CBCharacteristic *chacter = nil;
            CBUUID *serviceUUID = [CBUUID UUIDWithString:[GlobalConfig SubscribedService]];
            CBUUID *characteristicUUID = [CBUUID UUIDWithString:[GlobalConfig SubscribedCharacteristic]];
            
            for (CBService *service in peripheral.services)
            {
                if ([service.UUID isEqual:serviceUUID])
                {
                    for (CBCharacteristic *characteristic in service.characteristics)
                    {
                        if ([characteristic.UUID isEqual:characteristicUUID])
                        {
                            chacter = characteristic;
                            [peripheral setNotifyValue:YES forCharacteristic:chacter];
                        }
                        else
                        {
                            NSLog(@"%@, setCharacteristicNotification characteristicUUID 不相等!!!", [GlobalConfig DebugTag]);
                        }
                    }
                }
                else
                {
                    NSLog(@"%@, setCharacteristicNotification serviceUUID 不相等!!!", [GlobalConfig DebugTag]);
                }
            }
        }
    }
    else
    {
        NSLog(@"%@, setCharacteristicNotification something is nil!!!", [GlobalConfig DebugTag]);
    }
}

- (void)setCharacteristicNotificationCustom:(NSString *)aIdentifier service:(NSString *)aServiceString characteristic:(NSString *)aCharacteristicString
{
    if (_peripheralsDictionary != nil && aIdentifier != nil && aServiceString != nil && aCharacteristicString != nil)
    {
        CBPeripheral *peripheral = [_peripheralsDictionary objectForKey:aIdentifier];
        if (peripheral != nil)
        {
            CBCharacteristic *chacter = nil;
            CBUUID *serviceUUID = [CBUUID UUIDWithString:aServiceString];
            CBUUID *characteristicUUID = [CBUUID UUIDWithString:aCharacteristicString];
            
            for (CBService *service in peripheral.services)
            {
                if ([service.UUID isEqual:serviceUUID])
                {
                    for (CBCharacteristic *characteristic in service.characteristics)
                    {
                        if ([characteristic.UUID isEqual:characteristicUUID])
                        {
                            chacter = characteristic;
                            [peripheral setNotifyValue:YES forCharacteristic:chacter];
                        }
                        else
                        {
                            NSLog(@"%@, setCharacteristicNotificationCustom characteristicUUID 不相等!!!", [GlobalConfig DebugTag]);
                        }
                    }
                }
                else
                {
                    NSLog(@"%@, setCharacteristicNotificationCustom serviceUUID 不相等!!!", [GlobalConfig DebugTag]);
                }
            }
            
        }
        else
        {
            NSLog(@"%@, setCharacteristicNotificationCustom peripheral is nil!!!", [GlobalConfig DebugTag]);
        }
    }
    else
    {
        NSLog(@"%@, setCharacteristicNotificationCustom something is nil!!!", [GlobalConfig DebugTag]);
    }
}

// 暫時不用了
- (CBCharacteristic *)getCharacteristic:(NSString *)aIdentifier service:(NSString *)aServiceString characteristic:(NSString *)aCharacteristicString
{
    CBCharacteristic *chacter = nil;
    
    if (_peripheralsDictionary != nil && aIdentifier != nil && aServiceString != nil && aCharacteristicString != nil)
    {
        CBPeripheral *peripheral = [_peripheralsDictionary objectForKey:aIdentifier];
        if (peripheral != nil)
        {
            CBUUID *serviceUUID = [CBUUID UUIDWithString:aServiceString];
            CBUUID *characteristicUUID = [CBUUID UUIDWithString:aCharacteristicString];
            
            for (CBService *service in peripheral.services)
            {
                if ([service.UUID isEqual:serviceUUID])
                {
                    for (CBCharacteristic *characteristic in service.characteristics)
                    {
                        if ([characteristic.UUID isEqual:characteristicUUID])
                        {
                            chacter = characteristic;
                        }
                        else
                        {
                            NSLog(@"%@, getCharacteristic方法 characteristicUUID 不相等!!!", [GlobalConfig DebugTag]);
                        }
                    }
                }
                else
                {
                    NSLog(@"%@, getCharacteristic方法 serviceUUID 不相等!!!", [GlobalConfig DebugTag]);
                }
            }
        }
        else
        {
            NSLog(@"%@, getCharacteristic方法 peripheral is nil!!!", [GlobalConfig DebugTag]);
        }
    }
    else
    {
        NSLog(@"%@, getCharacteristic方法 something is nil!!!", [GlobalConfig DebugTag]);
    }
    
    return chacter;
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central
{
    switch (central.state)
    {
        case CBManagerStateUnsupported:
            NSLog(@"%@, Central State: 不支援哦!", [GlobalConfig DebugTag]);
            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "不支援哦!");
            break;
            
        case CBManagerStateUnauthorized:
            NSLog(@"%@, Central State: 沒有取得授權哦!", [GlobalConfig DebugTag]);
            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "沒有取得授權哦!");
            break;
            
        case CBManagerStatePoweredOff:
            NSLog(@"%@, Central State: 沒開電源啦!", [GlobalConfig DebugTag]);
            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "沒開電源啦!");
            break;
            
        case CBManagerStatePoweredOn:
            NSLog(@"%@, Central State: Powered On!", [GlobalConfig DebugTag]);
            if (_isInitializing)
            {
                UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "Initialized");
            }
            _isInitializing = FALSE;
            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "Powered On!");
            // [self scanBluetoothPeripheral];
            break;
            
        case CBManagerStateUnknown:
            NSLog(@"%@, Central State: Unknown!", [GlobalConfig DebugTag]);
            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "Unknown!");
            break;
            
        default:
            break;
    }
}

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral
{
    if (_isInitializing && peripheral.state == CBManagerStatePoweredOn)
    {
        _isInitializing = FALSE;
        UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", "Initialized");
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral != nil && peripheral.name != nil)
    {
        if (_centralManager != nil)
        {
            if (_peripheralsDictionary != nil)
            {
                NSString *deviceName = [peripheral name];
                if ([deviceName rangeOfString:GlobalConfig.SC_BLE_NAME_HC].location != NSNotFound || [deviceName rangeOfString:GlobalConfig.SC_BLE_NAME].location != NSNotFound || [deviceName rangeOfString:GlobalConfig.SC_BLE_NAME2].location != NSNotFound || [deviceName rangeOfString:GlobalConfig.SC_BLE_NAME_LTC].location != NSNotFound)
                {
                    NSString *deviceIdentifier = [[peripheral identifier] UUIDString];
                    // NSURL *dictUrl = [_peripheralsDictionary objectForKey:deviceIdentifier];
                    
                    while ([_peripheralsDictionary objectForKey:deviceIdentifier] == nil)
                    {
                        [_peripheralsDictionary setObject:peripheral forKey:deviceIdentifier];
                        [_peripheralsList addObject:peripheral];
                    }
                    
                    
                    if ([_peripheralsList count] > 0)
                    {
                        for (int i = 0; i < [_peripheralsList count]; ++i)
                        {
                            CBPeripheral *device = [_peripheralsList objectAtIndex:i];
                            NSString *deviceInfo = [NSString stringWithFormat:@"%lu#%@#%@", [_peripheralsList count], device.name, device.identifier];
                            
                            // NSLog(@"%@, name: %@, identifier: %@", [GlobalConfig DebugTag], device.name, device.identifier);
                            UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "detectedDevices", [deviceInfo UTF8String]);
                        }
                    }
                    else
                    {
                        NSString *noDevice = @"0#null#null";
                        UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "detectedDevices", [noDevice UTF8String]);
                    }
                    
                    // 原來的方法
//                    if (dictUrl == nil)
//                    {
//                        [_peripheralsDictionary setObject:peripheral forKey:deviceIdentifier];
//                        [_peripheralsList addObject:peripheral];
//                        // NSLog(@"EthanLinBluetoothDataLib, name: %@, identifier: %@", peripheral.name, peripheral.identifier);
//
//                        NSString *deviceInfo = [NSString stringWithFormat:@"%@#%@", peripheral.name, peripheral.identifier];
//                        UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "detectedDevices", [deviceInfo UTF8String]);
//                    }
                }
            }
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSString *peripheralId = [[peripheral identifier] UUIDString];
    if (peripheralId != nil)
    {
        NSString *message = @"devicesConnected";
        NSString *nowDateString = [_dateFormatter stringFromDate:[NSDate date]];
        UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", [message UTF8String]);
        NSLog(@"%@ %@, 已連接至 %@", nowDateString, [GlobalConfig DebugTag], peripheralId);
        peripheral.delegate = self;
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (_peripheralsDictionary != nil)
    {
        NSString *message = @"devicesDisconnected";
        NSString *nowDateString = [_dateFormatter stringFromDate:[NSDate date]];
        UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", [message UTF8String]);
        NSLog(@"%@ %@, 已斷開連接", nowDateString, [GlobalConfig DebugTag]);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"%@, didDiscoverServices error %@", [GlobalConfig DebugTag], error.description);
        // UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", [message UTF8String] );
    }
    else
    {
        NSString *peripheralId = [[peripheral identifier] UUIDString];
        if (peripheralId != nil)
        {
            for (CBService *service in peripheral.services)
            {
                // NSLog(@"%@, 發現的service %@", [GlobalConfig DebugTag], service);
                
                [peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"%@, didDiscoverCharacteristicsForService error %@", [GlobalConfig DebugTag], error.description);
        // UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", [message UTF8String] );
    }
    else
    {
        NSString *peripheralId = [[peripheral identifier] UUIDString];
        if (peripheralId != nil)
        {
            for (CBCharacteristic *characteristic in service.characteristics)
            {
                // NSLog(@"%@, 發現的characteristic %@", [GlobalConfig DebugTag], characteristic);
            }
            
            [self setCharacteristicNotification:peripheralId];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"%@, didUpdateValueForCharacteristic error %@", [GlobalConfig DebugTag], error.description);
        // UnitySendMessage ([[GlobalConfig UnityGameObject] UTF8String], "receiveMessageFromNative", [message UTF8String] );
    }
    else
    {
        NSString *peripheralId = [[peripheral identifier] UUIDString];
        if (peripheralId != nil)
        {
            // NSLog(@"%@, characteristic uuid %@", [GlobalConfig DebugTag], [characteristic UUID]);
            if (_unityBluetoothDataLib != nil && characteristic.value != nil && (characteristic.value.length == GlobalConfig.DataSize36 || characteristic.value.length == GlobalConfig.DataSize20))
            {
                // _unityBluetoothDataLib handleBluetoothData:];
                // NSLog(@"EthanLinBluetoothDataLib, 收到資料長度為 %lu", (unsigned long)characteristic.value.length);
                
                // _upperId = [NSString stringWithFormat:@"%2@", characteristic.value];
                // NSLog(@"EthanLinBluetoothDataLib, 收到資料_upperId為 %@", _upperId);
                _data = characteristic.value;
                // [_unityBluetoothDataLib bleDataHandler:_data];
                NSString *finalDataString = [Utils byteArrayToBase64:_data length:(int)_data.length];
                UnitySendMessage([[GlobalConfig UnityGameObject] UTF8String], "receiveDataFromNative", [finalDataString UTF8String]);
            }
        }
    }
}


- (void)bleDataHandler:(NSData *)aData
{
    if ([[[Utils byteArrayToHexString:aData] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"E"])
    {
        NSData *chunkUpperId = [aData subdataWithRange:NSMakeRange(0, 1)];
        
        NSMutableData *upperTemp1 = [[aData subdataWithRange:NSMakeRange(1, 4)] mutableCopy];
        NSMutableData *upperTemp5 = [[aData subdataWithRange:NSMakeRange(5, 4)] mutableCopy];
        NSMutableData *upperTemp9 = [[aData subdataWithRange:NSMakeRange(9, 4)] mutableCopy];
        NSMutableData *upperTemp13 = [[aData subdataWithRange:NSMakeRange(13, 4)] mutableCopy];
        uint32_t *bytes1 = (uint32_t *)upperTemp1.mutableBytes;
        uint32_t *bytes5 = (uint32_t *)upperTemp5.mutableBytes;
        uint32_t *bytes9 = (uint32_t *)upperTemp9.mutableBytes;
        uint32_t *bytes13 = (uint32_t *)upperTemp13.mutableBytes;
        *bytes1 = CFSwapInt32(*bytes1);
        *bytes5 = CFSwapInt32(*bytes5);
        *bytes9 = CFSwapInt32(*bytes9);
        *bytes13 = CFSwapInt32(*bytes13);
        
        
        NSData *chunkDownId = [aData subdataWithRange:NSMakeRange(18, 1)];
        
        NSMutableData *downTemp19 = [[aData subdataWithRange:NSMakeRange(19, 4)] mutableCopy];
        NSMutableData *downTemp23 = [[aData subdataWithRange:NSMakeRange(23, 4)] mutableCopy];
        NSMutableData *downTemp27 = [[aData subdataWithRange:NSMakeRange(27, 4)] mutableCopy];
        NSMutableData *downTemp31 = [[aData subdataWithRange:NSMakeRange(31, 4)] mutableCopy];
        uint32_t *bytes19 = (uint32_t *)downTemp19.mutableBytes;
        uint32_t *bytes23 = (uint32_t *)downTemp23.mutableBytes;
        uint32_t *bytes27 = (uint32_t *)downTemp27.mutableBytes;
        uint32_t *bytes31 = (uint32_t *)downTemp31.mutableBytes;
        *bytes19 = CFSwapInt32(*bytes19);
        *bytes23 = CFSwapInt32(*bytes23);
        *bytes27 = CFSwapInt32(*bytes27);
        *bytes31 = CFSwapInt32(*bytes31);
        
        // NSString *dataString = [_unityBluetoothDataLib byteArrayToHexString:_data];
        
        _upperId = [Utils getBodyId:chunkUpperId];
        NSString *dataStringTemp1 = [Utils byteArrayToHexString:upperTemp1];
        NSString *dataStringTemp5 = [Utils byteArrayToHexString:upperTemp5];
        NSString *dataStringTemp9 = [Utils byteArrayToHexString:upperTemp9];
        NSString *dataStringTemp13 = [Utils byteArrayToHexString:upperTemp13];
        float upperFloatX = [Utils hexString2float:dataStringTemp5];
        float upperFloatY = [Utils hexString2float:dataStringTemp1] * -1;
        float upperFloatZ = [Utils hexString2float:dataStringTemp9] * -1;
        float upperFloatW = [Utils hexString2float:dataStringTemp13];
        
        _downId = [Utils getBodyId:chunkDownId];
        NSString *dataStringTemp19 = [Utils byteArrayToHexString:downTemp19];
        NSString *dataStringTemp23 = [Utils byteArrayToHexString:downTemp23];
        NSString *dataStringTemp27 = [Utils byteArrayToHexString:downTemp27];
        NSString *dataStringTemp31 = [Utils byteArrayToHexString:downTemp31];
        float downFloatX = [Utils hexString2float:dataStringTemp23];
        float downFloatY = [Utils hexString2float:dataStringTemp19] * -1;
        float downFloatZ = [Utils hexString2float:dataStringTemp27] * -1;
        float downFloatW = [Utils hexString2float:dataStringTemp31];
        
        // NSLog(@"%@, 收到資料為上半身id %@\n", [GlobalConfig DebugTag], _upperId);
        // NSLog(@"%@, 收到資料為下半身id %@\n", [GlobalConfig DebugTag], _downId);
        // NSLog(@"%@, 收到上半身資料為 (%.3f, %.3f, %.3f, %.3f)\n", [GlobalConfig DebugTag], upperFloatX, upperFloatY, upperFloatZ, upperFloatW);
        // NSLog(@"%@, 收到下半身資料為 (%.3f, %.3f, %.3f, %.3f)\n", [GlobalConfig DebugTag], downFloatX, downFloatY, downFloatZ, downFloatW);
        
        NSString *finalDataString = [NSString stringWithFormat:@"%@#%.3f#%.3f#%.3f#%.3f#%@#%.3f#%.3f#%.3f#%.3f", _upperId, upperFloatX, upperFloatY, upperFloatZ, upperFloatW, _downId, downFloatX, downFloatY, downFloatZ, downFloatW];
        
        UnitySendMessage([[GlobalConfig UnityGameObject] UTF8String], "receiveDataFromNative", [finalDataString UTF8String]);
    }
}

@end
