//
//  GlobalConfig.m
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/3/13.
//

#import "GlobalConfig.h"

static NSString *EthanDebugTag = @"EthanLinBluetoothDataLib";

static NSString *serviceUUID = @"FFE0";
static NSString *characteristicUUID = @"FFE1";

@implementation GlobalConfig

+ (NSString *)DebugTag
{
    return EthanDebugTag;
}

+ (NSString *)SubscribedService
{
    return serviceUUID;
}
+ (NSString *)SubscribedCharacteristic
{
    return characteristicUUID;
}

@end
