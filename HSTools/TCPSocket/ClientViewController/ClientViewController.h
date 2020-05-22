//
//  ClientViewController.h
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HSSocketFramework/HSSocketFramework.h>
#import "SubViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ClientViewController : NSViewController<HSSocketClientDelegate>
{
    IBOutlet NSButton *backBtn;
    
    IBOutlet NSTextField *ipField;
    IBOutlet NSTextField *portField;
    IBOutlet NSButton *connectBtn;
    IBOutlet NSButton *connectIntervalBtn;
    IBOutlet NSTextField *connectIntervalValField;
    
    IBOutlet NSTextField *inputField;
    IBOutlet NSButton *sendBtn;
    IBOutlet NSButton *sendClearBtn;
    IBOutlet NSButton *sendIntervalBtn;
    IBOutlet NSTextField *sendIntervalValField;
    IBOutlet NSButton *sendHexDataBtn;
    
    IBOutlet NSButton *recvHexDataBtn;
    IBOutlet NSButton *recvShowTimeBtn;
    IBOutlet NSButton *recvShowIPBtn;
    IBOutlet NSButton *recvShowPortBtn;
    IBOutlet NSButton *recvClearBtn;
    IBOutlet NSTextView *receivedTV;
    
    IBOutlet NSTextField *messageLabel;
    
}
@property (weak) id<SubViewControllerDelegate> delegate;

-(IBAction)backBtnAction:(id)sender;
//client setting
-(IBAction)connectBtnAction:(id)sender;
-(IBAction)connectIntervalBtnAction:(id)sender;
//send operate
-(IBAction)sendBtnAction:(id)sender;
-(IBAction)sendClearBtnAction:(id)sender;
-(IBAction)sendIntervalBtnAction:(id)sender;
-(IBAction)sendHexDataBtnAction:(id)sender;
//receive operate
-(IBAction)recvHexDataBtnAction:(id)sender;
-(IBAction)recvShowTimeBtnAction:(id)sender;
-(IBAction)recvShowIPBtnAction:(id)sender;
-(IBAction)recvShowPortBtnAction:(id)sender;
-(IBAction)recvClearBtnAction:(id)sender;
@end

NS_ASSUME_NONNULL_END
