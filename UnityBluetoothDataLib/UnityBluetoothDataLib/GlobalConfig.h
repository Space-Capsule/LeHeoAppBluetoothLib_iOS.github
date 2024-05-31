//
//  GlobalConfig.h
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/3/13.
//

#import <Foundation/Foundation.h>


@interface GlobalConfig : NSObject

+ (NSString *)DebugTag;

+ (NSString *)SubscribedService;
+ (NSString *)SubscribedCharacteristic;

@end

