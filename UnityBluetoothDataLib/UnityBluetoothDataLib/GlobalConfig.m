//
//  GlobalConfig.m
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/3/13.
//

#import "GlobalConfig.h"

static NSString *EthanDebugTag = @"EthanLinDebugTag";
static NSString *UnityGameObjectName = @"NativeBridge";

static NSString *serviceUUID = @"FFE0";
static NSString *characteristicUUID = @"FFE1";

static NSString *ScBleName = @"SC-BLE5";
static NSString *ScBleNameHC = @"HC-";
static NSString *ScBleName2 = @"SC-S0000";
static NSString *ScBleNameLTC = @"SC-LTC";

@implementation GlobalConfig

+ (NSString *)DebugTag
{
    return EthanDebugTag;
}

+ (NSString *)UnityGameObject
{
    return UnityGameObjectName;
}

+ (void)setUnityGameObjectName:(NSString *)aName
{
    UnityGameObjectName = aName;
}

+ (NSString *)SubscribedService
{
    return serviceUUID;
}
+ (NSString *)SubscribedCharacteristic
{
    return characteristicUUID;
}

+ (NSString *)SC_BLE_NAME
{
    return ScBleName;
}
+ (NSString *)SC_BLE_NAME_HC
{
    return ScBleNameHC;
}
+ (NSString *)SC_BLE_NAME2
{
    return ScBleName2;
}
+ (NSString *)SC_BLE_NAME_LTC
{
    return ScBleNameLTC;
}


+ (unsigned long)DataSize20
{
    return 20;
}
+ (unsigned long)DataSize36
{
    return 36;
}

@end
