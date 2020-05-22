//
//  ZMQSubscribeViewController.m
//  HSTools
//
//  Created by WeidongCao on 2020/5/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ZMQSubscribeViewController.h"

@interface ZMQSubscribeViewController ()
@property ZMQsubscriber *subscriber;
@property BOOL sendIntervalFlag;
@property dispatch_queue_t printLogQueue;
@end

@implementation ZMQSubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.showLogTimeFlag = YES;
    self.printLogQueue = dispatch_queue_create("com.zmqsubscriber.pringlogqueue", DISPATCH_QUEUE_SERIAL);
}
-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"zmqsubscriber",@"data":@"panel"}];
    }
}
-(IBAction)startBtnAction:(id)sender{
    if ([startBtn.title isEqualToString:@"Start"]) {
        NSString *url = [NSString stringWithFormat:@"%@:%@",[ipField stringValue],[portField stringValue]];
        [NSThread detachNewThreadWithBlock:^{
            self.subscriber = [[ZMQsubscriber alloc] init];
            [self.subscriber setDelegate:self];
            BOOL status = [self.subscriber initSubscriberWithUrl:url];
            NSLog(@"zmq subscriber init result:%hhd",status);
        }];
        [startBtn setTitle:@"Stop"];
        [ipField setEnabled:NO];
        [portField setEnabled:NO];
    }else{
        [self.subscriber stopSubscribe];
        self.subscriber = nil;
        [startBtn setTitle:@"Start"];
        [ipField setEnabled:YES];
        [portField setEnabled:YES];
        
    }
}
-(IBAction)clearBtnAction:(id)sender{
    logTextView.string  = @"";
}
-(void)receivedMessageFromZMQPublisher:(NSData *_Nonnull)data{
    if (data == nil) {
        return;
    }
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"zmq sub received:%@",message);
    NSString *log = [NSString stringWithFormat:@"[RX]%@",message];
    dispatch_async(self.printLogQueue, ^{
        [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
    });
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
