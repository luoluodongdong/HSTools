//
//  ZMQRPCClientViewController.h
//  HSTools
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ZMQlib/ZMQlib.h>
#import "SubViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMQRPCClientViewController : NSViewController
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *ipField;
    IBOutlet NSTextField *portField;
    IBOutlet NSButton *startBtn;
    
    IBOutlet NSTextView *inputTextView;
    IBOutlet NSButton *sendIntervalBtn;
    IBOutlet NSTextField *sendIntervalValField;
    IBOutlet NSTextField *timeoutField;
    IBOutlet NSButton *sendBtn;
    
    IBOutlet NSButton *clearBtn;
    IBOutlet NSButton *showTimeBtn;
    IBOutlet NSTextView *logTextView;
}
-(IBAction)backBtnAction:(id)sender;
-(IBAction)startBtnAction:(id)sender;
-(IBAction)sendBtnAction:(id)sender;
-(IBAction)sendIntervalBtnAction:(id)sender;

-(IBAction)clearBtnAction:(id)sender;
@property (nonatomic) BOOL showLogTimeFlag;
@property (weak) id<SubViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
