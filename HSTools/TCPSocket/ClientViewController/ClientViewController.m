//
//  ClientViewController.m
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ClientViewController.h"
#import "PublicDefines.h"
#import "ConvertTool.h"
#import "MyRegex.h"

@interface ClientViewController ()
@property HSSocketClient *socketClient;
//@property (retain, nonatomic) NSString *selectedClientName;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSMutableString *logString;
@property (retain, nonatomic) NSString *ip;
@property (assign, nonatomic) int port;
@property BOOL isUpdating;
@property dispatch_queue_t printLogQueue;

@property BOOL connectIntervalEnable;

@property BOOL sendIntervalEnable;
@property BOOL sendHexDataFlag;

@property BOOL recvHexDataFlag;
@property BOOL recvShowTimeFlag;
@property BOOL recvShowIPFlag;
@property BOOL recvShowPortFlag;
@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.socketClient = [[HSSocketClient alloc] init];
    [self setLogString:[NSMutableString string]];
    [self.socketClient setDelegate:self];
    [self.socketClient setAutoConnected:NO];
    self.printLogQueue = dispatch_queue_create("com.socketclient.printlogqueue",DISPATCH_QUEUE_SERIAL);
    self.isUpdating = NO;
    self.recvShowPortFlag = NO;
    self.recvShowTimeFlag = YES;
    self.recvShowIPFlag = NO;
    self.recvShowPortFlag = NO;
    self.connectIntervalEnable = NO;
}
-(void)viewWillAppear{
    self.timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
//自动刷新log view
-(void)timeTick{
    if (self.isUpdating == YES) {
            return;
        }
        self.isUpdating = YES;
        NSUInteger textLen = self->receivedTV.textStorage.length;
        if (textLen > 500000) {
            [self->receivedTV.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
        }
        NSString *log = [self safeReadLog];
        if ([log isEqualToString:@""]) {
            self.isUpdating = NO;
            return;
        }
        // 设置字体颜色NSForegroundColorAttributeName，取值为 UIColor对象，默认值为黑色
        NSMutableAttributedString *textColor = [[NSMutableAttributedString alloc] initWithString:log];
    //        [textColor addAttribute:NSForegroundColorAttributeName
    //                          value:[NSColor greenColor]
    //                          range:[@"NSAttributedString设置字体颜色" rangeOfString:@"NSAttributedString"]];
        [textColor addAttribute:NSForegroundColorAttributeName
                          value:[NSColor systemGreenColor]
                          range:NSMakeRange(0, log.length)];
        
        //NSAttributedString *attrStr=[[NSAttributedString alloc] initWithString:self.logString];
        textLen = textLen + log.length;
        [self->receivedTV.textStorage appendAttributedString:textColor];
        [self->receivedTV scrollRangeToVisible:NSMakeRange(textLen,0)];
        self.isUpdating = NO;
}
//存 log
-(void)safeAppendLog:(NSString *)log{
    @synchronized (self) {
        NSMutableString *string = self.logString;
        NSString *dateText = @"";
        NSString *ip = @"";
        NSString *port = @"";
        //time
        if (self.recvShowTimeFlag == YES) {
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yy/MM/dd HH:mm:ss.SSS "];
            dateText=[dateFormat stringFromDate:[NSDate date]];
        }
        //ip
        if (self.recvShowIPFlag == YES) {
            ip = [NSString stringWithFormat:@"(%@) ",self.ip];
        }
        //port
        if (self.recvShowPortFlag == YES) {
            port = [NSString stringWithFormat:@"[%d] ",self.port];
        }
        [string appendFormat:@"%@%@%@%@\r\n",dateText,ip,port,log];
        [self setLogString:string];
    }
}
//取 log
-(NSString *)safeReadLog{
    @synchronized (self) {
        NSMutableString *logStr = self.logString;
        [self setLogString:[NSMutableString string]];
        return logStr;
    }
}
-(void)viewWillDisappear{
    [self.timer invalidate];
    self.timer = nil;
}
-(IBAction)connectBtnAction:(id)sender{
    if ([connectBtn.title isEqualToString:@"Connect"]) {
        self.ip = [ipField stringValue];
        if (self.ip.length ==0 || [MyRegex validateIP:self.ip] == NO) {
            [self show:MSG_LEVEL_ERROR message:@"[error]ip invalidate!"];
        }
        NSString *port = [portField stringValue];
        if (port.length == 0 || [MyRegex validateAllNumber:port] == NO) {
            [self show:MSG_LEVEL_ERROR message:@"[error]port invalidate!"];
        }
        self.port = [portField intValue];
        BOOL status = [self.socketClient connectToServerIP:self.ip port:self.port];
        if(status == YES){
            [self show:MSG_LEVEL_INFO message:[NSString stringWithFormat:@"[info]client connect status:%hhd",status]];
        }else{
            [self show:MSG_LEVEL_ERROR message:[NSString stringWithFormat:@"[error]client connect status:%hhd",status]];
        }
    }else{
        [self.socketClient disconnect];
        [self disconnectAction];
    }
}
-(void)connectedAction{
    [connectBtn setTitle:@"Disconnect"];
    [ipField setEnabled:NO];
    [portField setEnabled:NO];
    [connectIntervalBtn setEnabled:NO];
    [connectIntervalValField setEnabled:NO];
    dispatch_async(self.printLogQueue, ^{
        @autoreleasepool {
            [self safeAppendLog:@"[info]client connected server successfully!"];
            //[NSThread sleepForTimeInterval:0.01];
        }
    });
}
-(void)disconnectAction{
    [connectBtn setTitle:@"Connect"];
    [self show:MSG_LEVEL_ERROR message:@"[error]client disconnected!"];
    [ipField setEnabled:YES];
    [portField setEnabled:YES];
    [connectIntervalBtn setEnabled:YES];
    [connectIntervalValField setEnabled:YES];
    dispatch_async(self.printLogQueue, ^{
        @autoreleasepool {
            [self safeAppendLog:@"[error]client disconnected!"];
            //[NSThread sleepForTimeInterval:0.01];
        }
    });
}
//send commands
-(IBAction)sendBtnAction:(id)sender{
    if ([self beforSendCheckIsReady] == NO) {
        return;
    }
    NSString *cmd = [inputField stringValue];
    [NSThread detachNewThreadWithBlock:^{
        NSData *data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
        if (self.sendHexDataFlag == YES) {
             data = [ConvertTool convertHexStrToData:cmd];
        }
        [self.socketClient sendCommand:data];
//        NSString *response = [self.socketServer queryClientName:self.selectedClientName cmd:cmd timeout:3.0];
//        NSLog(@"socket response:%@",response);
    }];
}
//clear commands
-(IBAction)sendClearBtnAction:(id)sender{
    [inputField setStringValue:@""];
}
//循环发送commands
-(IBAction)sendIntervalBtnAction:(id)sender{
    self.sendIntervalEnable = [sendIntervalBtn state];
    if (self.sendIntervalEnable == NO) {
        [sendIntervalValField setEnabled:YES];
        return;
    }
    if ([sendIntervalValField doubleValue] == 0) {
        [self show:MSG_LEVEL_ERROR message:@"[error]interval value invalidate!"];
        return;
    }
    if ([self beforSendCheckIsReady] == NO) {
        return;
    }
    [sendIntervalValField setEnabled:NO];
    NSString *cmd = [inputField stringValue];
    double sendIntervalVal = [sendIntervalValField doubleValue];
    [NSThread detachNewThreadWithBlock:^{
        while (1) {
            if (self.sendIntervalEnable == NO) {
                NSLog(@"repeat send finished");
                break;
            }
            [NSThread sleepForTimeInterval:sendIntervalVal];
            NSString *msg = [NSString stringWithFormat:@"[TX]%@",cmd];
            dispatch_async(self.printLogQueue, ^{
                @autoreleasepool {
                    [self safeAppendLog:msg];
                    //[NSThread sleepForTimeInterval:0.01];
                }
            });
            NSData *data = [cmd dataUsingEncoding:NSUTF8StringEncoding];
            if (self.sendHexDataFlag == YES) {
                 data = [ConvertTool convertHexStrToData:cmd];
            }
            [self.socketClient sendCommand:data];
        }
    }];
}
//发送command之前check
-(BOOL)beforSendCheckIsReady{
    NSString *cmd = [inputField stringValue];
    if (cmd.length == 0) {
        return NO;
    }
    if (self.socketClient.isReady == NO) {
        [self show:MSG_LEVEL_ERROR message:@"[error]haven't connected server!"];
        return NO;
    }
    NSString *msg = [NSString stringWithFormat:@"[TX]%@",cmd];
    dispatch_async(self.printLogQueue, ^{
        @autoreleasepool {
            [self safeAppendLog:msg];
            //[NSThread sleepForTimeInterval:0.01];
        }
    });
    return YES;
}
-(IBAction)connectIntervalBtnAction:(id)sender{
    self.connectIntervalEnable = connectIntervalBtn.state;
    if (self.connectIntervalEnable) {
        self.socketClient.autoConnected = YES;
        self.socketClient.connectInterval = [connectIntervalValField doubleValue];
        [connectIntervalValField setEnabled:NO];
    }else{
        self.socketClient.autoConnected = NO;
        [connectIntervalValField setEnabled:YES];
    }
}
//发送十六进制数据
-(IBAction)sendHexDataBtnAction:(id)sender{
    self.sendHexDataFlag = sendHexDataBtn.state;
}
//接收十六进制数据
-(IBAction)recvHexDataBtnAction:(id)sender{
    self.recvHexDataFlag = recvHexDataBtn.state;
}
//log显示接收时间戳
-(IBAction)recvShowTimeBtnAction:(id)sender{
    self.recvShowTimeFlag = recvShowTimeBtn.state;
}
//log显示client ip
-(IBAction)recvShowIPBtnAction:(id)sender{
    self.recvShowIPFlag = recvShowIPBtn.state;
}
//log显示client port
-(IBAction)recvShowPortBtnAction:(id)sender{
    self.recvShowPortFlag = recvShowPortBtn.state;
}
//清空log
-(IBAction)recvClearBtnAction:(id)sender{
    self.logString = [NSMutableString string];
    [receivedTV.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    [self.logString appendString:@"clear log OK\r\n"];
}

-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"client",@"data":@"panel"}];
    }
}
#pragma mark -- delegate socket client
//NSDictionary *event = @{@"type":@"error",@"data":@"read data TIMEOUT"};
//NSDictionary *event = @{@"type":@"connect",@"data":@"online"};
//NSDictionary *event = @{@"type":@"received",@"data":self.readData}; //data class:<NSData>
//NSDictionary *event = @{@"type":@"disconnect",@"data":@"offline"};
-(void)eventFromSocketClient:(NSDictionary *)event{
    NSLog(@"event from socket client:%@",event);
    NSString *type = [event objectForKey:@"type"];
    if ([type isEqualToString:@"error"]) {
        NSString *msg = [event objectForKey:@"data"];
        [self show:MSG_LEVEL_ERROR message:[NSString stringWithFormat:@"[error]%@",msg]];
        dispatch_async(self.printLogQueue, ^{
            @autoreleasepool {
                [self safeAppendLog:msg];
                //[NSThread sleepForTimeInterval:0.01];
            }
        });
    }
    else if([type isEqualToString:@"received"]){
        NSData *data = [event objectForKey:@"data"];
        NSString *receivedStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (self.recvHexDataFlag == YES) {
            receivedStr = [ConvertTool convertDataToHexStr:data];
        }
        NSString *msg = [NSString stringWithFormat:@"[RX]%@",receivedStr];
        dispatch_async(self.printLogQueue, ^{
            @autoreleasepool {
                [self safeAppendLog:msg];
                //[NSThread sleepForTimeInterval:0.01];
            }
        });
    }
    else if ([type isEqualToString:@"connect"]){
        if ([[NSThread currentThread] isMainThread]) {
            [self connectedAction];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self connectedAction];
            });
        }
    }
    else if ([type isEqualToString:@"disconnect"]){
        if ([[NSThread currentThread] isMainThread]) {
            [self disconnectAction];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self disconnectAction];
            });
        }
    }
}

//底部显示提示信息
-(void)show:(MSG_LEVEL )level message:(NSString *)message{
    NSColor *color = [NSColor blackColor];
    if (level == MSG_LEVEL_WARN) {
        color = [NSColor systemYellowColor];
    }else if(level == MSG_LEVEL_ERROR){
        color = [NSColor systemRedColor];
    }
    if ([[NSThread currentThread] isMainThread]) {
        [messageLabel setStringValue:message];
        [messageLabel setTextColor:color];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->messageLabel setStringValue:message];
            [self->messageLabel setTextColor:color];
        });
    }
}

@end
