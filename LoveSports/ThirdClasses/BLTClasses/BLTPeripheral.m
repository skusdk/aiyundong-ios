//
//  BLTPeripheral.m
//  ProductionTest
//
//  Created by zorro on 15-1-16.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTPeripheral.h"
#import "BLTUUID.h"

@interface BLTPeripheral ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableData *receiveData;

@end

@implementation BLTPeripheral

DEF_SINGLETON(BLTPeripheral)

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _receiveData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;
    
    if (peripheral)
    {
        [self startUpdateRSSI];
    }
    else
    {
        [self stopUpdateRSSI];
    }
}

- (void)startUpdateRSSI
{
    [self stopTimer];
    
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(updateRSSI) userInfo:nil repeats:YES];
    }
}

- (void)updateRSSI
{
    if (_peripheral)
    {
        [_peripheral readRSSI];
    }
}

- (void)stopUpdateRSSI
{
    [self stopTimer];
}

- (void)stopTimer
{
    if (_timer)
    {
        if ([_timer isValid])
        {
            [_timer invalidate];
            _timer = nil;
        }
    }
}

#pragma mark --- CBPeripheralDelegate ---
// 发现该设备所持有的所有服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"发生错误.");
    }
    
    for (CBService *service in peripheral.services)
    {
        if ([service.UUID isEqual:BLTUUID.uartServiceUUID])
        {
            // self.blService = service;
            //[_peripheral discoverCharacteristics:nil forService:service];
            [_peripheral discoverCharacteristics:@[BLTUUID.txCharacteristicUUID, BLTUUID.rxCharacteristicUUID] forService:service];

        }
        else if ([service.UUID isEqual:BLTUUID.deviceInformationServiceUUID])
        {
            [_peripheral discoverCharacteristics:@[BLTUUID.hardwareRevisionStringUUID] forService:service];
        }
        
        
        NSLog(@"service.UUID. = .%@.", service.UUID);
    }
}

// 发现该服务所持有的所有特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"特征错误...");
    }
    
    for (CBCharacteristic *charac in service.characteristics)
    {
        if ([charac.UUID isEqual:BLTUUID.rxCharacteristicUUID])
        {
            [_peripheral setNotifyValue:YES forCharacteristic:charac];
            
            [[BLTSendData sharedInstance] sendContinuousInstruction];
        }
        else if ([charac.UUID isEqual:BLTUUID.txCharacteristicUUID])
        {
            [_peripheral setNotifyValue:YES forCharacteristic:charac];
            
            if (_connectBlock)
            {
                _connectBlock();
            }
        }
        else if ([charac.UUID isEqual:BLTUUID.hardwareRevisionStringUUID]) // 绑定
        {
            NSLog(@"硬件信息.");
        }

        NSLog(@"charac. = .%@..", charac);
    }
}

#pragma mark --- CBPeripheralDelegate 数据更新 ---
// 时时更新信号强度
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    if (_RSSIBlock)
    {
        NSInteger rssi = ABS([RSSI integerValue]);
        _RSSIBlock(rssi);
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (_RSSIBlock)
    {
        NSInteger rssi = ABS([peripheral.RSSI integerValue]);
        _RSSIBlock(rssi);
    }
}

// 向设备写数据时会触发该代理...
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"写数据时发生错误...%@", error);
        if (_failBlock)
        {
            _failBlock();
        }
    }
    else
    {
        NSLog(@"写入成功。");
    }
}

// 外围设备数据有更新时会触发该方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"数据更新错误...");
        
        if (_failBlock)
        {
            _failBlock();
        }
    }
    else
    {
        NSLog(@"数据更新%@\n", characteristic.value);
        if ([characteristic.UUID isEqual:BLTUUID.txCharacteristicUUID])
        {
            [self cleanMutableData:_receiveData];
            [_receiveData appendData:characteristic.value];
            if (_updateBlock)
            {
                _updateBlock(_receiveData);
            }
        }
        if ([characteristic.UUID isEqual:BLTUUID.rxCharacteristicUUID])
        {
            [self cleanMutableData:_receiveData];
            [_receiveData appendData:characteristic.value];
            
            if (_updateBigDataBlock)
            {
                _updateBigDataBlock(_receiveData);
            }
        }
    }
}

#pragma mark --- receiveData 数据清空 ---
- (void)cleanMutableData:(NSMutableData *)data
{
    [data resetBytesInRange:NSMakeRange(0, data.length)];
    [data setLength:0];
}

// 错误信息提示
- (void)errorMessage
{
    if (_failBlock)
    {
        _failBlock();
    }
}

@end
