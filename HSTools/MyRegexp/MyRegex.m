//
//  MyRegex.m
//  RegularTest
//
//  Created by WeidongCao on 2020/5/12.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "MyRegex.h"

@implementation MyRegex

//邮箱
+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
  
//手机号码验证
+ (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}
  
//车牌号验证
+ (BOOL) validateCarNo:(NSString *)carNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}
  
//车型
+ (BOOL) validateCarType:(NSString *)CarType
{
    NSString *CarTypeRegex = @"^[\u4E00-\u9FFF]+$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CarTypeRegex];
    return [carTest evaluateWithObject:CarType];
}
  
//用户名
+ (BOOL) validateUserName:(NSString *)name
{
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    BOOL B = [userNamePredicate evaluateWithObject:name];
    return B;
}
  
//密码
+ (BOOL) validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]\\S{6,20}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}
  
//昵称
+ (BOOL) validateNickname:(NSString *)nickname
{
    NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}
  
//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//ip地址
+ (BOOL) validateIP:(NSString *)ip{
    NSString *theRegex = @"^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\.(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)$";
    NSPredicate *theTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theRegex];
    return [theTest evaluateWithObject:ip];
}
//string
+ (BOOL)validateAllString:(NSString *)str{
    NSString *theRegex = @"[a-zA-Z]*";
    NSPredicate *theTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theRegex];
    return [theTest evaluateWithObject:str];
}
//number
+ (BOOL)validateAllNumber:(NSString *)num{
    NSString *theRegex = @"[0-9]*";
    NSPredicate *theTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theRegex];
    return [theTest evaluateWithObject:num];
}
//endpoint
+ (BOOL)validateEndpoint:(NSString *)endpoint{
    NSString *theRegex = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}:[0-9]*$";
    NSPredicate *theTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theRegex];
    return [theTest evaluateWithObject:endpoint];
}
//全汉字
+ (BOOL)validateAllChinese:(NSString *)str{
    NSString *theRegex = @"[\u4e00-\u9fa5]+";
    NSPredicate *theTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", theRegex];
    return [theTest evaluateWithObject:str];
}
@end
