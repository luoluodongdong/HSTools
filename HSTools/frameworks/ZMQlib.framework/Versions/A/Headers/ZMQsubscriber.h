//
//  ZMQsubscriber.h
//  OCZMQTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMQObjC.h"

@protocol ZMQsubscriberDelegate <NSObject>

-(void)receivedMessageFromZMQPublisher:(NSData *_Nonnull)data;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZMQsubscriber : NSObject

@property (weak) id<ZMQsubscriberDelegate> delegate;
//url: 127.0.0.1:5555
-(BOOL)initSubscriberWithUrl:(NSString *)url;
-(void)stopSubscribe;
@end

NS_ASSUME_NONNULL_END
