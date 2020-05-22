//
//  ServerViewController.h
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HSSocketFramework/HSSocketFramework.h>
#import "SubViewControllerProtocol.h"
#import "MyRegex.h"
#import "ConvertTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface ServerViewController : NSViewController<HSSocketServerDelegate>
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *ipField;
    IBOutlet NSTextField *portField;
    IBOutlet NSButton *listeningBtn;
    IBOutlet NSPopUpButton *clientListBtn;
    
    IBOutlet NSTextField *inputField;
    IBOutlet NSButton *sendBtn;
    IBOutlet NSButton *sendClearBtn;
    IBOutlet NSButton *intervalBtn;
    IBOutlet NSTextField *intervalValueField;
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
//server setting
-(IBAction)listeningBtnAction:(id)sender;
-(IBAction)clientListBtnAction:(id)sender;
//send operate
-(IBAction)sendBtnAction:(id)sender;
-(IBAction)sendClearBtnAction:(id)sender;
-(IBAction)intervalBtnAction:(id)sender;
-(IBAction)sendHexDataBtnAction:(id)sender;
//receive operate
-(IBAction)recvHexDataBtnAction:(id)sender;
-(IBAction)recvShowTimeBtnAction:(id)sender;
-(IBAction)recvShowIPBtnAction:(id)sender;
-(IBAction)recvShowPortBtnAction:(id)sender;
-(IBAction)recvClearBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
