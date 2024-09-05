//
//  UnityBluetoothDataLib.h
//  UnityBluetoothDataLib
//
//  Created by EthanLin on 2024/2/17.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#import "GlobalConfig.h"
#import "Utils.h"

@interface UnityBluetoothDataLib : NSObject<CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>
{
    // NSString *_debugTag;
    NSDateFormatter *_dateFormatter;
    
    CBCentralManager *_centralManager;
    
    NSMutableDictionary *_peripheralsDictionary;
    NSMutableArray *_peripheralsList;
    
    NSString *_peripheralName;
    
    // BOOL _isPaused;
    // BOOL _alreadyNotified;
    BOOL _isInitializing;
    
    NSString *_upperId;
    NSString *_downId;
        
    NSData *_data;
}

@property (atomic, strong) NSMutableDictionary *_peripheralsDictionary;

@property NSString *_upperId;
@property NSString *_downId;
@property NSData *_data;

- (void)initBluetoothManager;
- (void)scanBluetoothPeripheral;
- (void)stopScan;
- (void)connectToDevice:(NSString *)aIdentifier;
- (void)disconnectAllBluetoothDevice;
- (void)setCharacteristicNotification:(NSString *)aIdentifier;
- (void)setCharacteristicNotificationCustom:(NSString *)aIdentifier service:(NSString *)aServiceString characteristic:(NSString *)aCharacteristicString;
- (CBCharacteristic *)getCharacteristic:(NSString *)aIdentifier service:(NSString *)aServiceString characteristic:(NSString *)aCharacteristicString;
// 將收到的資料轉成Quaternion
- (void)bleDataHandler:(NSData *)aData;

@end
