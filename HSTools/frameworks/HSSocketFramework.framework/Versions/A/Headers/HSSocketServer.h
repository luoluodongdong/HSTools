//
//  HSSocketServer.h
//  HSSocketTest
//
//  Created by WeidongCao on 2020/5/14.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "ConnectedClient.h"

@protocol HSSocketServerDelegate <NSObject>
//NSDictionary *event = @{@"type":@"error",@"data":@"client name error"};
//NSDictionary *event = @{@"type":@"error",@"data":@"read data TIMEOUT"};
//NSDictionary *event = @{@"type":@"newClient",@"data":client}; client class : <ConnectedClient>
//NSDictionary *event = @{@"type":@"removeClient",@"data":client};
//name : client-0 / unknown      message class: <NSData>
//NSDictionary *event = @{@"type":@"received",@"data":@{@"name":name,@"message":message}};
-(void)eventFromSocketServer:(NSDictionary *_Nonnull)event;

@end

NS_ASSUME_NONNULL_BEGIN

@interface HSSocketServer : NSObject<GCDAsyncSocketDelegate>
//all connected client : (class : <ConnectedClient>)
@property (readonly) NSMutableArray *clientNamesArray;
//all connected client names : client-0/client-1/...
@property (readonly) NSMutableDictionary *clientList;
@property (weak) id<HSSocketServerDelegate> delegate;
//ip : 127.0.0.1 port : 5555
-(BOOL)startListening:(NSString *)ip port:(int )port;
-(void)stopListening;
//name : client-0
-(BOOL)sendCommand:(NSData *)cmd clientName:(NSString *)name;
//timeout : 2.0s
//*nend run in sub thread
-(NSData *)queryClientName:(NSString *)name cmd:(NSData *)cmd timeout:(double )to;

@end

NS_ASSUME_NONNULL_END
