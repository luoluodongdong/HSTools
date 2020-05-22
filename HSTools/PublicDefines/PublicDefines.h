//
//  PublicDefines.h
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/16.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MSG_LEVEL) {
    MSG_LEVEL_INFO = 0x01,
    MSG_LEVEL_WARN = 0x02,
    MSG_LEVEL_ERROR = 0x03,
};

#ifdef DEBUG
    #define CNLog(aParam, ...)      NSLog(@"%s(%d): " aParam, ((strrchr(__FILE__, '/') ? : __FILE__- 1) + 1), __LINE__, ##__VA_ARGS__)
    #define CNLogForRect(aRect)     CNLog(@"[%s] x: %f, y: %f, width: %f, height: %f", #aRect, aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height)
    #define CNLogForRange(aRange)   CNLog(@"[%s] location: %lu; length: %lu", #aRange, aRange.location, aRange.length)
#else
    #define CNLog(xx, ...)          ((void)0)
    #define CNLogRect(aRect)        ((void)0)
    #define CNLogRange(aRange)      ((void)0)
#endif

