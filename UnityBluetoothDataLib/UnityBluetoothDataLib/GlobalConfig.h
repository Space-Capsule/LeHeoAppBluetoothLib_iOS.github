//
//  GlobalConfig.h
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/3/13.
//

#import <Foundation/Foundation.h>


@interface GlobalConfig : NSObject

+ (NSString *)DebugTag;
+ (NSString *)UnityGameObject;
+ (void)setUnityGameObjectName:(NSString *)aName;

+ (NSString *)SubscribedService;
+ (NSString *)SubscribedCharacteristic;

+ (NSString *)SC_BLE_NAME;
+ (NSString *)SC_BLE_NAME_HC;
+ (NSString *)SC_BLE_NAME2;
+ (NSString *)SC_BLE_NAME_LTC;

@end

