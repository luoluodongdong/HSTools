//
//  ServerReplyItem.h
//  HSTools
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerReplyItem : NSObject<NSCoding>
@property NSString *request;
@property NSString *response;
+(instancetype)initWithRequst:(NSString *)request response:(NSString *)response;
@end

NS_ASSUME_NONNULL_END
