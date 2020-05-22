//
//  ConvertTool.h
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConvertTool : NSObject

// 将十六进制字符串转换成NSData "61 62 63" -> "abc"
+ (NSData *)convertHexStrToData:(NSString *)str;

// 将NSData转换成十六进制的字符串 "abc" -> "61 62 63"
+ (NSString *)convertDataToHexStr:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
