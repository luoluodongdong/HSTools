//
//  ZMQRPCServerViewController.m
//  HSTools
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ZMQRPCServerViewController.h"

@interface ZMQRPCServerViewController ()
@property ZMQreplyer *rpcServer;
@property dispatch_queue_t printLogQueue;
@property dispatch_queue_t replyQueue;
@end

@implementation ZMQRPCServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.showLogTimeFlag = YES;
    self.printLogQueue = dispatch_queue_create("com.zmqrpcserver.pringlogqueue", DISPATCH_QUEUE_SERIAL);
    self.replyQueue = dispatch_queue_create("com.zmqrpcserver.replyqueue", DISPATCH_QUEUE_SERIAL);
    self.replyItemsArray = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *dataItem = [defaults objectForKey:@"com.zmqrpcserver.replylist.key"];
    if (dataItem == nil) {
        ServerReplyItem *item = [ServerReplyItem initWithRequst:@"hello" response:@"world"];
        NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:@[item]];
        [defaults setObject:saveData forKey:@"com.zmqrpcserver.replylist.key"];
    }else{
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:dataItem];;
        for (ServerReplyItem *item in array) {
            [self.replyArrayController addObject:item];
        }
    }
}
-(void)viewWillAppear{
//    for (int i=0; i<10; i++) {
//        NSString *request = [NSString stringWithFormat:@"request-%d",i];
//        NSString *response = [NSString stringWithFormat:@"response-%d",i];
//        ServerReplyItem *item = [ServerReplyItem initWithRequst:request response:response];
//        [self.replyArrayController addObject:item];
//    }
//
//    NSLog(@"self.replyArrayController:%@",self.replyItemsArray);
    
}

-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"zmqrpcserver",@"data":@"panel"}];
    }
}
-(IBAction)addBtnAction:(id)sender{
    ServerReplyItem *item = [ServerReplyItem initWithRequst:@"hello" response:@"world"];
    [self.replyArrayController addObject:item];
}
-(IBAction)saveBtnAction:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempArray = self.replyItemsArray;
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:tempArray];
    [defaults setObject:saveData forKey:@"com.zmqrpcserver.replylist.key"];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:@"save done" waitUntilDone:YES];
    });
}
-(IBAction)startBtnAction:(id)sender{
    if ([startBtn.title isEqualToString:@"Start"]) {
        NSString *url = [NSString stringWithFormat:@"%@:%@",[ipField stringValue],[portField stringValue]];
        [NSThread detachNewThreadWithBlock:^{
            self.rpcServer = [[ZMQreplyer alloc] init];
            [self.rpcServer setDelegate:self];
            BOOL status = [self.rpcServer initReplyerWithUrl:url];
            NSLog(@"zmq rpc server init result:%hhd",status);
        }];
        [startBtn setTitle:@"Stop"];
        [ipField setEnabled:NO];
        [portField setEnabled:NO];
    }else{
        [self.rpcServer stopReplyer];
        self.rpcServer = nil;
        self.rpcServer.delegate = nil;
        [startBtn setTitle:@"Start"];
        [ipField setEnabled:YES];
        [portField setEnabled:YES];
        
    }
}
# pragma mark -- Delegate ZMQReplyer
-(void)receivedRequestFromZMQreplyer:(NSData *_Nonnull)data{
    if (data == nil) {
        return;
    }
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"zmq replyer received:%@",message);
    dispatch_async(self.replyQueue, ^{
        [self replyTheRequest:message];
    });
}
-(void)replyTheRequest:(NSString *)request{
    NSString *log = [NSString stringWithFormat:@"[RX]%@",request];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
    });
    NSString *response = [self getResponseWithRequest:request];
    log = [NSString stringWithFormat:@"[TX]%@",response];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
    });
    [self.rpcServer sendResponse:response];
}
-(NSString *)getResponseWithRequest:(NSString *)request{
    for (ServerReplyItem *item in self.replyItemsArray) {
        if ([item.request isEqualToString:request]) {
            return item.response;
        }
    }
    return [NSString stringWithFormat:@"bad request:%@",request];
}
-(IBAction)clearBtnAction:(id)sender{
    logTextView.string  = @"";
}
-(void)updateLog:(NSString *)log{
    NSUInteger textLen = self->logTextView.textStorage.length;
        if (textLen > 500000) {
            [self->logTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
        }
    NSMutableString *logStr = [NSMutableString string];
    NSString *dateText = @"";
    //time
    if (self.showLogTimeFlag) {
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yy/MM/dd HH:mm:ss.SSS "];
        dateText=[dateFormat stringFromDate:[NSDate date]];
    }
    [logStr appendFormat:@"%@%@\r\n",dateText,log];
        // 设置字体颜色NSForegroundColorAttributeName，取值为 UIColor对象，默认值为黑色
        NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc] initWithString:logStr];
    //        [textColor addAttribute:NSForegroundColorAttributeName
    //                          value:[NSColor greenColor]
    //                          range:[@"NSAttributedString设置字体颜色" rangeOfString:@"NSAttributedString"]];
        [textColor addAttribute:NSForegroundColorAttributeName
                          value:[NSColor systemGreenColor]
                          range:NSMakeRange(0, logStr.length)];
        
        //NSAttributedString *attrStr=[[NSAttributedString alloc] initWithString:self.logString];
        textLen = textLen + logStr.length;
        [self->logTextView.textStorage appendAttributedString:textColor];
        [self->logTextView scrollRangeToVisible:NSMakeRange(textLen,0)];
}
@end
