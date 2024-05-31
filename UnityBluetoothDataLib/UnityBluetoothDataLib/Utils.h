//
//  Utils.h
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/3/13.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject

/* 取得id */
+ (NSString *)getBodyId:(NSData *)aData;

/* byte array to hex-string */
+ (NSString *)byteArrayToHexString:(NSData *)aData;

+ (float)hexString2float:(NSString *)aDataString;

+ (NSString *)byteArrayToBase64:(NSData *)aData length:(int)aLength;

@end

