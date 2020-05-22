//
//  SerialViewController.m
//  HSTools
//
//  Created by WeidongCao on 2020/5/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "SerialViewController.h"

@interface SerialViewController ()

@property (retain, nonatomic) NSMutableString *logString;
@property BOOL isUpdating;
@property (retain, nonatomic) NSTimer *timer;
@property dispatch_queue_t printLogQueue;

@end

@implementation SerialViewController
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
        self.availableBaudRates = @[@300, @1200, @2400, @4800, @9600, @14400, @19200, @28800, @38400, @57600, @115200, @230400];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
        [nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.isUpdating = NO;
    self.logString = [NSMutableString string];
    self.printLogQueue = dispatch_queue_create("com.serialport.printlogqueue", DISPATCH_QUEUE_SERIAL);
    self.shouldAddLineEnding = YES;
    self.showLogTimeFlag = YES;
    self.intervalSendFlag = NO;
    self.intervalSendFlag = NO;
}
#pragma mark - Actions

// Private
- (NSString *)lineEndingString
{
    NSDictionary *map = @{@0: @"\r", @1: @"\n", @2: @"\r\n"};
    NSString *result = map[@(self.lineEndingPopUpButton.selectedTag)];
    return result ?: @"\n";
}
-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"serialport",@"data":@"panel"}];
    }
}
-(IBAction)stopBitsBtnAction:(id)sender{
    NSButton *btn = sender;
    NSLog(@"stopbits:%@",btn.title);
    self.serialPort.numberOfStopBits = [btn.title integerValue];
}
-(IBAction)parityBtnAction:(id)sender{
    NSButton *btn = sender;
    NSLog(@"parity:%@",btn.title);
    if ([btn.title isEqualToString:@"None"]) {
        self.serialPort.parity = ORSSerialPortParityNone;
    }else if([btn.title isEqualToString:@"Odd"]){
        self.serialPort.parity = ORSSerialPortParityOdd;
    }else if([btn.title isEqualToString:@"Even"]){
        self.serialPort.parity = ORSSerialPortParityEven;
    }
}
-(IBAction)sendIntervalBtnAction:(id)sender{
    self.intervalSendFlag = self.sendIntervalBtn.state;
    if (self.intervalSendFlag) {
        [self.sendIntervalValField setEnabled:NO];
    }else{
        [self.sendIntervalValField setEnabled:YES];
    }
}
-(IBAction)sendClearCmdBtnAction:(id)sender{
    self.sendTextView.string = @"";
}
- (IBAction)send:(id)sender
{
    NSString *string = [self.sendTextView.textStorage string];
    if (string.length == 0) {
        return;
    }
    [self.sendButton setEnabled:NO];
    NSString *log = [NSString stringWithFormat:@"[TX]%@",[string copy]];
    dispatch_async(self.printLogQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateLog:log];
        });
    });
    if (self.shouldAddLineEnding && ![string hasSuffix:[self lineEndingString]]) {
        string = [string stringByAppendingString:[self lineEndingString]];
    }
    NSData *dataToSend = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self.serialPort sendData:dataToSend];
    if (self.intervalSendFlag) {
        double intervalVal = [self.sendIntervalValField doubleValue];
        [NSThread detachNewThreadWithBlock:^{
            while (self.intervalSendFlag) {
                [NSThread sleepForTimeInterval:intervalVal];
                NSString *log = [NSString stringWithFormat:@"[TX]%@",[string copy]];
                dispatch_async(self.printLogQueue, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateLog:log];
                    });
                });
                [self.serialPort sendData:dataToSend];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.sendButton setEnabled:YES];
            });
        }];
    }else{
        [self.sendButton setEnabled:YES];
    }
}

- (IBAction)returnPressedInTextField:(id)sender
{
    [self.sendButton performClick:sender];
}

- (IBAction)openOrClosePort:(id)sender
{
    self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];
}

- (IBAction)clear:(id)sender
{
    self.receivedDataTextView.string = @"";
}
-(void)viewWillAppear{
//    self.timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(timeTick) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
//自动刷新log view
-(void)timeTick{
    if (self.isUpdating == YES) {
            return;
        }
        self.isUpdating = YES;
        NSUInteger textLen = self->_receivedDataTextView.textStorage.length;
        if (textLen > 500000) {
            [self->_receivedDataTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
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
        [self->_receivedDataTextView.textStorage appendAttributedString:textColor];
        [self->_receivedDataTextView scrollRangeToVisible:NSMakeRange(textLen,0)];
        self.isUpdating = NO;
}
//存 log
-(void)safeAppendLog:(NSString *)log{
    @synchronized (self) {
        NSMutableString *string = self.logString;
        NSString *dateText = @"";
        //time
        NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"[yy/MM/dd HH:mm:ss.SSS] "];
        dateText=[dateFormat stringFromDate:[NSDate date]];
        [string appendFormat:@"%@%@\r\n",dateText,log];
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
//    [self.timer invalidate];
//    self.timer = nil;
}
#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
    self.openCloseButton.title = @"Close";
    [self.portsBtn setEnabled:NO];
    [self.baudBtn setEnabled:NO];
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
    self.openCloseButton.title = @"Open";
    [self.portsBtn setEnabled:YES];
    [self.baudBtn setEnabled:YES];
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([string length] == 0) return;
    [self.logString appendString:string];
    if ([self.logString hasSuffix:@"\r\n"]) {
        NSString *log = [NSString stringWithFormat:@"[RX]%@",[self.logString copy]];
        dispatch_async(self.printLogQueue, ^{
            [self performSelectorOnMainThread:@selector(updateLog:) withObject:log waitUntilDone:YES];
        });
        [self.logString setString:@""];
    }
}
-(void)updateLog:(NSString *)log{
    NSUInteger textLen = self->_receivedDataTextView.textStorage.length;
        if (textLen > 500000) {
            [self->_receivedDataTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
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
        [self->_receivedDataTextView.textStorage appendAttributedString:textColor];
        [self->_receivedDataTextView scrollRangeToVisible:NSMakeRange(textLen,0)];
}
- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
    // After a serial port is removed from the system, it is invalid and we must discard any references to it
    self.serialPort = nil;
    self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
    NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}

#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [center removeDeliveredNotification:notification];
    });
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#endif

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
    NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
    NSLog(@"Ports were connected: %@", connectedPorts);
    [self postUserNotificationForConnectedPorts:connectedPorts];
    
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
    NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
    NSLog(@"Ports were disconnected: %@", disconnectedPorts);
    [self postUserNotificationForDisconnectedPorts:disconnectedPorts];
    
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in connectedPorts)
    {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [unc deliverNotification:userNote];
    }
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
    if (!NSClassFromString(@"NSUserNotificationCenter")) return;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    for (ORSSerialPort *port in disconnectedPorts)
    {
        NSUserNotification *userNote = [[NSUserNotification alloc] init];
        userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
        NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
        userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
        userNote.soundName = nil;
        [unc deliverNotification:userNote];
    }
#endif
}


#pragma mark - Properties

- (void)setSerialPort:(ORSSerialPort *)port
{
    if (port != _serialPort)
    {
        [_serialPort close];
        _serialPort.delegate = nil;
        
        _serialPort = port;
        
        _serialPort.delegate = self;
    }
}
@end
