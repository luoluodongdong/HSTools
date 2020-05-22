//
//  ConnectedClient.h
//  HSSocketTest
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConnectedClient : NSObject

@property (assign, nonatomic) int index;
@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSString *ip;
@property (assign, nonatomic) int port;
@property GCDAsyncSocket *socket;

+(instancetype)initWithSocket:(GCDAsyncSocket *)socket name:(NSString *)name index:(int )index ip:(NSString *)ip port:(int )port;

@end

NS_ASSUME_NONNULL_END
