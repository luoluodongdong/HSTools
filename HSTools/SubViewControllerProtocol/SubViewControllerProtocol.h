//
//  SubViewControllerProtocol.h
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SubViewControllerDelegate <NSObject>
//{@"name":@"panel",@"data":@"server"}
//{@"name":@"panel",@"data":@"client"}
//{@"name":@"server",@"data":@"panel"}
//{@"name":@"client",@"data":@"panel"}
-(void)eventFromSubViewController:(NSDictionary *)event;

@end

NS_ASSUME_NONNULL_END
