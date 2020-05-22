//
//  MyRegex.h
//  RegularTest
//
//  Created by WeidongCao on 2020/5/12.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyRegex : NSObject
//邮箱
+ (BOOL) validateEmail:(NSString *)email;
//手机号码验证
+ (BOOL) validateMobile:(NSString *)mobile;
//车牌号验证
+ (BOOL) validateCarNo:(NSString *)carNo;
//车型
+ (BOOL) validateCarType:(NSString *)CarType;
//用户名
+ (BOOL) validateUserName:(NSString *)name;
//密码
+ (BOOL) validatePassword:(NSString *)passWord;
//昵称
+ (BOOL) validateNickname:(NSString *)nickname;
//身份证号
+ (BOOL) validateIdentityCard:(NSString *)identityCard;
//ip地址
+ (BOOL) validateIP:(NSString *)ip;
//string
+ (BOOL)validateAllString:(NSString *)str;
//number
+ (BOOL)validateAllNumber:(NSString *)num;
//endpoint "127.0.0.1:10052"
+ (BOOL)validateEndpoint:(NSString *)endpoint;
//全汉字
+ (BOOL)validateAllChinese:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
