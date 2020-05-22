//
//  ZMQRPCServerViewController.h
//  HSTools
//
//  Created by WeidongCao on 2020/5/19.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ZMQlib/ZMQlib.h>
#import "SubViewControllerProtocol.h"
#import "ServerReplyItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZMQRPCServerViewController : NSViewController<ZMQreplerDelegate>
{
    IBOutlet NSButton *backBtn;
    IBOutlet NSTextField *ipField;
    IBOutlet NSTextField *portField;
    IBOutlet NSButton *startBtn;
    
    IBOutlet NSTableView *tableView;
    IBOutlet NSButton *addBtn;
    IBOutlet NSButton *removeBtn;
    IBOutlet NSButton *saveBtn;
    
    IBOutlet NSButton *clearBtn;
    IBOutlet NSButton *showTimeBtn;
    IBOutlet NSTextView *logTextView;
}
-(IBAction)backBtnAction:(id)sender;
-(IBAction)startBtnAction:(id)sender;


-(IBAction)clearBtnAction:(id)sender;
-(IBAction)addBtnAction:(id)sender;
-(IBAction)saveBtnAction:(id)sender;

@property (nonatomic) BOOL showLogTimeFlag;
@property (weak) id<SubViewControllerDelegate> delegate;
@property (retain, nonatomic) NSMutableArray *replyItemsArray;
@property (retain, nonatomic) IBOutlet NSArrayController *replyArrayController;

@end

NS_ASSUME_NONNULL_END
