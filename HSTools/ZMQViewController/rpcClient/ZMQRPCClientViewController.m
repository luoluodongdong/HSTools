//
//  ZMQRPCClientViewController.m
//  HSTools
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ZMQRPCClientViewController.h"

@interface ZMQRPCClientViewController ()
@property ZMQrequester *rpcClient;
@property BOOL sendIntervalFlag;
@property dispatch_queue_t printLogQueue;
@end

@implementation ZMQRPCClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.showLogTimeFlag = YES;
    self.sendIntervalFlag = NO;
    self.printLogQueue = dispatch_queue_create("com.zmqrpclient.pringlogqueue", DISPATCH_QUEUE_SERIAL);
}
-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"zmqrpcclient",@"data":@"panel"}];
    }
}
-(IBAction)startBtnAction:(id)sender{
    if ([startBtn.title isEqualToString:@"Start"]) {
        NSString *url = [NSString stringWithFormat:@"%@:%@",[ipField stringValue],[portField stringValue]];
        [NSThread detachNewThreadWithBlock:^{
            self.rpcClient = [[ZMQrequester alloc] init];
            BOOL status = [self.rpcClient initRequesterWithUrl:url];
            NSLog(@"zmq rpc client init result:%hhd",status);
        }];
        [startBtn setTitle:@"Stop"];
        [ipField setEnabled:NO];
        [portField setEnabled:NO];
    }else{
        [self.rpcClient stopRequester];
        self.rpcClient = nil;
        [startBtn setTitle:@"Start"];
        [ipField setEnabled:YES];
        [portField setEnabled:YES];
        
    }
}
-(IBAction)sendBtnAction:(id)sender{
    NSString *cmd = [inputTextView.textStorage string];
    if (cmd.length == 0) {
        return;
    }
    NSUInteger timeout = [timeoutField integerValue];
    NSString *log = [NSString stringWithFormat:@"[TX]%@",cmd];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
    });
    NSString *response = [self.rpcClient queryWithCmd:cmd timeout:timeout];
    log = [NSString stringWithFormat:@"[RX]%@",response];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
    });
    if (self.sendIntervalFlag) {
        [sendBtn setEnabled:NO];
        double interval = [sendIntervalValField doubleValue];

        [NSThread detachNewThreadWithBlock:^{
            while (self.sendIntervalFlag) {
                [NSThread sleepForTimeInterval:interval];
                NSString *log = [NSString stringWithFormat:@"[TX]%@",cmd];
                dispatch_async(self.printLogQueue, ^{
                    [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
                });
                NSString *response = [self.rpcClient queryWithCmd:cmd timeout:timeout];
                log = [NSString stringWithFormat:@"[RX]%@",response];
                dispatch_async(self.printLogQueue, ^{
                    [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->sendBtn setEnabled:YES];
            });
        }];
    }
}
-(IBAction)sendIntervalBtnAction:(id)sender{
    self.sendIntervalFlag = [sendIntervalBtn state];
    if (self.sendIntervalFlag) {
        [sendIntervalValField setEnabled:NO];
    }else{
        [sendIntervalValField setEnabled:YES];
    }
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
