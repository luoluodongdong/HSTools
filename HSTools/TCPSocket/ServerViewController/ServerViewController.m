//
//  ServerViewController.m
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "ServerViewController.h"
#import "PublicDefines.h"

@interface ServerViewController ()
@property HSSocketServer *socketServer;
@property (retain, nonatomic) NSString *selectedClientName;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSMutableString *logString;
@property BOOL isUpdating;
@property dispatch_queue_t printLogQueue;
@property BOOL sendIntervalEnable;
@property BOOL sendHexDataFlag;

@property BOOL recvHexDataFlag;
@property BOOL recvShowTimeFlag;
@property BOOL recvShowIPFlag;
@property BOOL recvShowPortFlag;


@end

@implementation ServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.socketServer = [[HSSocketServer alloc] init];
    self.selectedClientName = @"";
    [self setLogString:[NSMutableString string]];
    [self.socketServer setDelegate:self];
    self.printLogQueue = dispatch_queue_create("com.socketserver.printlogqueue",DISPATCH_QUEUE_SERIAL);
    self.isUpdating = NO;
    self.recvShowPortFlag = NO;
    self.recvShowTimeFlag = YES;
    self.recvShowIPFlag = NO;
    self.recvShowPortFlag = NO;
    [clientListBtn removeAllItems];
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
        ConnectedClient *client = [self.socketServer.clientList objectForKey:self.selectedClientName];
        //ip
        if (self.recvShowIPFlag == YES) {
            ip = [NSString stringWithFormat:@"(%@) ",client.ip];
        }
        //port
        if (self.recvShowPortFlag == YES) {
            port = [NSString stringWithFormat:@"[%d] ",client.port];
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
//server listening/stop
-(IBAction)listeningBtnAction:(id)sender{
    if ([listeningBtn.title isEqualToString:@"Listening"]) {
        NSString *ip = [ipField stringValue];
        if (ip.length ==0 || [MyRegex validateIP:ip] == NO) {
            [self show:MSG_LEVEL_ERROR message:@"[error]ip invalidate!"];
        }
        NSString *port = [portField stringValue];
        if (port.length == 0 || [MyRegex validateAllNumber:port] == NO) {
            [self show:MSG_LEVEL_ERROR message:@"[error]port invalidate!"];
        }
        BOOL status = [self.socketServer startListening:ip port:[portField intValue]];
        if(status == YES){
            [listeningBtn setTitle:@"Stop"];
            [ipField setEnabled:NO];
            [portField setEnabled:NO];
            [self show:MSG_LEVEL_INFO message:[NSString stringWithFormat:@"[info]server listening status:%hhd",status]];
        }else{
            [self show:MSG_LEVEL_ERROR message:[NSString stringWithFormat:@"[error]server listening status:%hhd",status]];
        }
    }else{
        [self.socketServer stopListening];
        [listeningBtn setTitle:@"Listening"];
        [self show:MSG_LEVEL_INFO message:@"[info]server listening stopped."];
        [ipField setEnabled:YES];
        [portField setEnabled:YES];
    }
    
}
//connected clients list
-(IBAction)clientListBtnAction:(id)sender{
    NSString *item = [[clientListBtn selectedItem] title];
    NSArray *tempArr = [item componentsSeparatedByString:@" : "];
    self.selectedClientName = [tempArr objectAtIndex:0];
    [self show:MSG_LEVEL_INFO message:[NSString stringWithFormat:@"[info]selected client name:%@",self.selectedClientName]];
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
        [self.socketServer sendCommand:data clientName:self.selectedClientName];
//        NSString *response = [self.socketServer queryClientName:self.selectedClientName cmd:cmd timeout:3.0];
//        NSLog(@"socket response:%@",response);
    }];
}
//clear commands
-(IBAction)sendClearBtnAction:(id)sender{
    [inputField setStringValue:@""];
}
//循环发送commands
-(IBAction)intervalBtnAction:(id)sender{
    self.sendIntervalEnable = [intervalBtn state];
    if (self.sendIntervalEnable == NO) {
        [intervalValueField setEnabled:YES];
        return;
    }
    if ([intervalValueField doubleValue] == 0) {
        [self show:MSG_LEVEL_ERROR message:@"[error]interval value invalidate!"];
        return;
    }
    if ([self beforSendCheckIsReady] == NO) {
        return;
    }
    [intervalValueField setEnabled:NO];
    NSString *cmd = [inputField stringValue];
    double sendIntervalVal = [intervalValueField doubleValue];
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
            [self.socketServer sendCommand:data clientName:self.selectedClientName];
        }
    }];
}
//发送command之前check
-(BOOL)beforSendCheckIsReady{
    NSString *cmd = [inputField stringValue];
    if (cmd.length == 0) {
        return NO;
    }
    if ([self.selectedClientName isEqualToString:@""]) {
        [self show:MSG_LEVEL_ERROR message:@"[error]no any connected client!"];
        return NO;
    }
    NSLog(@"self.selectedClientName:%@",self.selectedClientName);
    NSString *msg = [NSString stringWithFormat:@"[TX]%@",cmd];
    dispatch_async(self.printLogQueue, ^{
        @autoreleasepool {
            [self safeAppendLog:msg];
            //[NSThread sleepForTimeInterval:0.01];
        }
    });
    return YES;
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
//返回主panel
-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"server",@"data":@"panel"}];
    }
}
//更新已连接client list
-(void)updateClientListBtn{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->clientListBtn removeAllItems];
        if ([self.socketServer.clientList count] > 0) {
            for (NSString *name in self.socketServer.clientList) {
                ConnectedClient *client = [self.socketServer.clientList objectForKey:name];
                NSString *item = [NSString stringWithFormat:@"%@ : %@ : %d",client.name,client.ip,client.port];
                [self->clientListBtn addItemWithTitle:item];
            }
            //[self->clientListBtn addItemsWithTitles:self.socketServer.clientNamesArray];
            if ([self.socketServer.clientNamesArray count] == 1) {
                self.selectedClientName = [self.socketServer.clientNamesArray objectAtIndex:0];
            }
            ConnectedClient *client = [self.socketServer.clientList objectForKey:self.selectedClientName];
            NSString *item = [NSString stringWithFormat:@"%@ : %@ : %d",client.name,client.ip,client.port];
            NSUInteger index = [self->clientListBtn.itemTitles indexOfObject:item];
            [self->clientListBtn selectItemAtIndex:index];
        }else{
            self.selectedClientName = @"";
        }
        
    });
}
#pragma mark -- delegate socket server
//NSDictionary *event = @{@"type":@"error",@"data":@"client name error"};
//NSDictionary *event = @{@"type":@"error",@"data":@"read data TIMEOUT"};
//NSDictionary *event = @{@"type":@"newClient",@"data":client}; client class : <ConnectedClient>
//NSDictionary *event = @{@"type":@"removeClient",@"data":client};
//message <NSData>
//NSDictionary *event = @{@"type":@"received",@"data":@{@"name":name,@"message":message}}; name : client-0 / unknown
-(void)eventFromSocketServer:(NSDictionary *_Nonnull)event{
    NSLog(@"event from socket server:%@",event);
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
        NSDictionary *data = [event objectForKey:@"data"];
        NSData *message = [data objectForKey:@"message"];
        NSString *receivedStr = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
        if (self.recvHexDataFlag == YES) {
            receivedStr = [ConvertTool convertDataToHexStr:message];
        }
        NSString *msg = [NSString stringWithFormat:@"[RX]%@",receivedStr];
        dispatch_async(self.printLogQueue, ^{
            @autoreleasepool {
                [self safeAppendLog:msg];
                //[NSThread sleepForTimeInterval:0.01];
            }
        });
    }
    else if([type isEqualToString:@"newClient"]){
        ConnectedClient *client = [event objectForKey:@"data"];
        [self show:MSG_LEVEL_INFO message:[NSString stringWithFormat:@"[info]new client:%@ ip:%@ port:%d",client.name,client.ip,client.port]];
        [self updateClientListBtn];
    }
    else if([type isEqualToString:@"removeClient"]){
        ConnectedClient *client = [event objectForKey:@"data"];
        [self show:MSG_LEVEL_WARN message:[NSString stringWithFormat:@"[warning]remove client:%@ ip:%@ port:%d",client.name,client.ip,client.port]];
        [self updateClientListBtn];
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
