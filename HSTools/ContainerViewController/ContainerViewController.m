//
//  ContainerViewController.m
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ContainerViewController.h"

@interface ContainerViewController ()

@property (retain, nonatomic) MainPanelViewController *panelVC;
//socket
@property (retain, nonatomic) ServerViewController *socketserverVC;
@property (retain, nonatomic) ClientViewController *socketclientVC;

@property (retain, nonatomic) SFCQueryViewController *sfcqueryVC;
@property (retain, nonatomic) SerialViewController *serialVC;
@property (retain, nonatomic) ZMQPublishViewController *zmqpublishVC;
@property (retain, nonatomic) ZMQSubscribeViewController *zmqsubscribeVC;
@property (retain, nonatomic) ZMQRPCClientViewController *zmqrpcclientVC;
@property (retain, nonatomic) ZMQRPCServerViewController *zmqrpcserverVC;
@property (retain, nonatomic) NSViewController *currentVC;

@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.panelVC = [[MainPanelViewController alloc] init];
    [self.panelVC setDelegate:self];
    self.socketclientVC = [[ClientViewController alloc] init];
    [self.socketclientVC setDelegate:self];
    self.socketserverVC = [[ServerViewController alloc] init];
    [self.socketserverVC setDelegate:self];
    self.sfcqueryVC = [[SFCQueryViewController alloc] init];
    [self.sfcqueryVC setDelegate:self];
    self.serialVC = [[SerialViewController alloc] init];
    [self.serialVC setDelegate:self];
    self.zmqpublishVC = [[ZMQPublishViewController alloc] init];
    [self.zmqpublishVC setDelegate:self];
    self.zmqsubscribeVC = [[ZMQSubscribeViewController alloc] init];
    [self.zmqsubscribeVC setDelegate:self];
    self.zmqrpcclientVC = [[ZMQRPCClientViewController alloc] init];
    [self.zmqrpcclientVC setDelegate:self];
    self.zmqrpcserverVC = [[ZMQRPCServerViewController alloc] init];
    [self.zmqrpcserverVC setDelegate:self];
    
    self.currentVC = nil;
    [self loadChildVC:self.panelVC];
}
-(void)loadChildVC:(NSViewController *)childVC{
    [self.currentVC.view removeFromSuperview];
    [self.currentVC removeFromParentViewController];
    childVC.view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    [self addChildViewController:childVC];
    self.currentVC = childVC;
    [childVC.view setFrameSize:self.view.frame.size];
    [self.view addSubview:childVC.view];
}





-(void)eventFromSubViewController:(NSDictionary *)event{
    NSString *data = [event objectForKey:@"data"];
    if ([data isEqualToString:@"panel"]) {
        [self loadChildVC:self.panelVC];
    }
    else if([data isEqualToString:@"socketserver"]){
        [self loadChildVC:self.socketserverVC];
    }
    else if([data isEqualToString:@"socketclient"]){
        [self loadChildVC:self.socketclientVC];
    }
    else if ([data isEqualToString:@"sfcquery"]){
        [self loadChildVC:self.sfcqueryVC];
    }
    else if ([data isEqualToString:@"serialport"]){
        [self loadChildVC:self.serialVC];
    }
    else if ([data isEqualToString:@"zmqpublish"]){
        [self loadChildVC:self.zmqpublishVC];
    }
    else if ([data isEqualToString:@"zmqsubscribe"]){
        [self loadChildVC:self.zmqsubscribeVC];
    }
    else if ([data isEqualToString:@"zmqrpcclient"]){
        [self loadChildVC:self.zmqrpcclientVC];
    }
    else if ([data isEqualToString:@"zmqrpcserver"]){
        [self loadChildVC:self.zmqrpcserverVC];
    }
}
@end
