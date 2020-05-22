//
//  ServerReplyItem.m
//  HSTools
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ServerReplyItem.h"

@implementation ServerReplyItem
- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeObject:self.request forKey:@"request"];
    [coder encodeObject:self.response forKey:@"response"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder{
    if (self = [super init]) {
        self.request = [coder decodeObjectForKey:@"request"];
        self.response = [coder decodeObjectForKey:@"response"];
    }
    return self;
}
+(instancetype)initWithRequst:(NSString *)request response:(NSString *)response{
    ServerReplyItem *item = [[ServerReplyItem alloc] init];
    item.request = request;
    item.response = response;
    return item;
}
@end
