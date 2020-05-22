//
//  ZMQpublisher.h
//  HSLogPrintTest
//
//  Created by WeidongCao on 2020/5/13.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZMQObjC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMQpublisher : NSObject
//url: 127.0.0.1:5555
-(BOOL)initPublisherWithUrl:(NSString *)url;
-(void)publishMessage:(NSString *)message;
-(void)stopPublisher;
@end

NS_ASSUME_NONNULL_END
