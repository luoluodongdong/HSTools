//
//  SFCQueryViewController.m
//  HSTools
//
//  Created by WeidongCao on 2020/5/16.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "SFCQueryViewController.h"
#import "PublicDefines.h"

@interface SFCQueryViewController ()
@property dispatch_queue_t saveConfigsQueue;
@property (retain, nonatomic) NSMutableArray *urlArray;
@property (retain, nonatomic) NSTimer *timer;
@property (retain, nonatomic) NSMutableString *logString;
@property BOOL isUpdating;
@property (retain, nonatomic) NSColor *messageColor;
@end

@implementation SFCQueryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [urlComboBox setHasVerticalScroller:YES];
    [urlComboBox setCompletes:YES];
    [urlComboBox removeAllItems];
    self.saveConfigsQueue = dispatch_queue_create("com.sfcquery.saveconfigsqueue", DISPATCH_QUEUE_SERIAL);
    [self setLogString:[NSMutableString string]];
    self.isUpdating = NO;
    self.messageColor = [NSColor systemGreenColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setObject:@[@"http://10.33.20.147/bobcat/sfc_response.aspx"] forKey:@"com.sfcquery.urlkey"];
    //[defaults setObject:@"c=QUERY_RECORD&sn=12345&tsid=MLB Check SN01&p=UNIT_PROCESS_CHECK" forKey:@"com.sfcquery.datakey"];
    if ([defaults objectForKey:@"com.sfcquery.urlkey"] == nil) {
        [defaults setObject:@[@"http://10.33.20.147/bobcat/sfc_response.aspx"] forKey:@"com.sfcquery.urlkey"];
        [urlComboBox addItemsWithObjectValues:@[@"http://10.33.20.147/bobcat/sfc_response.aspx"]];
        [urlComboBox selectItemAtIndex:0];
        self.urlArray = [NSMutableArray arrayWithArray:@[@"http://10.33.20.147/bobcat/sfc_response.aspx"]];
    }else{
         NSArray *arr = [defaults objectForKey:@"com.sfcquery.urlkey"];
        self.urlArray = [NSMutableArray arrayWithArray:arr];
        [urlComboBox addItemsWithObjectValues:self.urlArray];
        [urlComboBox selectItemWithObjectValue:self.urlArray.lastObject];
    }
    if ([defaults objectForKey:@"com.sfcquery.datakey"] == nil) {
        [defaults setObject:@"c=QUERY_RECORD&sn=12345&tsid=MLB Check SN01&p=UNIT_PROCESS_CHECK" forKey:@"com.sfcquery.datakey"];
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:@"c=QUERY_RECORD&sn=12345&tsid=MLB Check SN01&p=UNIT_PROCESS_CHECK"];
        [dataTextView.textStorage setAttributedString:attString];
    }else{
        NSString *dataStr = [defaults objectForKey:@"com.sfcquery.datakey"];
        [dataTextView.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:dataStr]];
    }
    
}

-(IBAction)backBtnAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
        [self.delegate eventFromSubViewController:@{@"name":@"sfcquery",@"data":@"panel"}];
    }
}

-(void)controlTextDidChange:(NSNotification*)notification{
    id object = notification.object;
    NSLog(@"object:%@",object);
    //[urlComboBox performClick:nil];
}
-(IBAction)clearLogBtnAction:(id)sender{
    self.logString = [NSMutableString string];
    [receivedTV.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    [self printMsg:@"clear log OK" level:MSG_LEVEL_INFO];
}
-(IBAction)postOrGetBtnAction:(id)sender{
    if ([postBtn state]) {
        [postBtn setState:YES];
        [getBtn setState:NO];
    }else{
        [postBtn setState:NO];
        [getBtn setState:YES];
    }
}
-(IBAction)queryBtnAction:(id)sender{
    NSString *urlStr = [urlComboBox stringValue];
    NSLog(@"urlStr:%@",urlStr);
    NSString *dataStr = [[dataTextView textStorage] string];
    NSLog(@"dataStr:%@",dataStr);
    NSString *method = @"POST";
    if ([getBtn state]) {
        method = @"GET";
    }
    [queryBtn setEnabled:NO];
    [NSThread detachNewThreadWithBlock:^{
        [self printMsg:@"waiting..." level:MSG_LEVEL_WARN];
        NSError *err = NULL;
        NSString *response = [self testUrl:urlStr body:dataStr method:method error:&err];
        if (err == NULL) {
            [self printMsg:response level:MSG_LEVEL_INFO];
            dispatch_async(self.saveConfigsQueue, ^{
                [self saveURL:[urlStr copy] andDATA:[dataStr copy]];
            });
        }else{
            [self printMsg:[err localizedDescription] level:MSG_LEVEL_ERROR];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->queryBtn setEnabled:YES];
        });
    }];
    
}

-(void)saveURL:(NSString *)url andDATA:(NSString *)data{
    if ([url isEqualToString:@""] || [data isEqualToString:@""]) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([self->_urlArray containsObject:url] == NO) {
        [self->_urlArray addObject:url];
        [defaults setObject:self->_urlArray forKey:@"com.sfcquery.urlkey"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->urlComboBox addItemWithObjectValue:url];
        });
    }
    [defaults setObject:data forKey:@"com.sfcquery.datakey"];
}

-(NSString *)testUrl:(NSString *)url body:(NSString *)body method:(NSString *)method error:(NSError *__strong*)err{
    *err = [[NSError alloc] initWithDomain:@"com.hstools.sfcquery.requesterror" code:0x03 userInfo:@{NSLocalizedDescriptionKey:@"request appear error!"}];
    //创建信号量,实现同步请求
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    NSURLSession *session=[NSURLSession sharedSession];
    //第一步，创建URL
    //NSString *urlString=@"http://10.37.66.2:8005/LuxShare_QualityTestService.aspx";
    //第二步，创建请求
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:method];
    [request setTimeoutInterval:10.0f];
    //request.HTTPMethod=@"GET";
    //NSString *strData = [NSString stringWithFormat:@"c=QUERY_RECORD&sn=%@&StationID=%@&cmd=QUERY_PANEL", strSN, strStation];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];

    //第三步，连接服务器
    NSString static *strReceivedData = @"";
    NSURLSessionDataTask *task=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"error:%@",error);
        if (data != nil) {
            *err = NULL;
            strReceivedData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",strReceivedData);
        }else{
            *err = error;
        }
        //发送
        dispatch_semaphore_signal(semaphore);
    }];
    
    [task resume];
    //等待(阻塞线程)
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"task finish");
    
    return strReceivedData;
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
                          value:self.messageColor
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

-(void)printMsg:(NSString *)msg level:(MSG_LEVEL )level{
    if (level == MSG_LEVEL_INFO) {
        self.messageColor = [NSColor systemGreenColor];
    }else if (level == MSG_LEVEL_WARN){
        self.messageColor = [NSColor systemYellowColor];
    }else if (level == MSG_LEVEL_ERROR){
        self.messageColor = [NSColor systemRedColor];
    }
    [self safeAppendLog:msg];
    [self performSelectorOnMainThread:@selector(timeTick) withObject:nil waitUntilDone:YES];
}
@end
