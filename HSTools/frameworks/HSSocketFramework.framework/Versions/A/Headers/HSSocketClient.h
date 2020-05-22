//
//  HSSocketClient.h
//  HSSocketTest
//
//  Created by WeidongCao on 2020/5/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HSSocketClientDelegate <NSObject>
//NSDictionary *event = @{@"type":@"error",@"data":@"read data TIMEOUT"};
//NSDictionary *event = @{@"type":@"connect",@"data":@"online"};
//NSDictionary *event = @{@"type":@"received",@"data":self.readData}; //data class:<NSData>
//NSDictionary *event = @{@"type":@"disconnect",@"data":@"offline"};
-(void)eventFromSocketClient:(NSDictionary *)event;

@end

@interface HSSocketClient : NSObject<GCDAsyncSocketDelegate>

@property (readonly) BOOL isReady; //clinet current status online/offline
@property BOOL autoConnected; //default value : YES
@property double connectInterval; //default value : 5.0
@property (weak) id<HSSocketClientDelegate> delegate;
//ip : 127.0.0.1 port : 5555
-(BOOL)connectToServerIP:(NSString *)ip port:(int)port;
-(void)disconnect;

-(void)sendCommand:(NSData *)cmd;
//timeout : 2.0 s
//*need run in sub thread
-(NSData *)query:(NSData *)cmd timeout:(double )to;

@end

NS_ASSUME_NONNULL_END
