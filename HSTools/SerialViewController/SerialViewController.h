//
//  SerialViewController.h
//  HSTools
//
//  Created by WeidongCao on 2020/5/18.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ORSSerial/ORSSerial.h>
#import "SubViewControllerProtocol.h"

@class ORSSerialPortManager;
NS_ASSUME_NONNULL_BEGIN


@interface SerialViewController : NSViewController<ORSSerialPortDelegate>

- (IBAction)send:(id)sender;
- (IBAction)openOrClosePort:(id)sender;
- (IBAction)clear:(id)sender; //clear log
-(IBAction)backBtnAction:(id)sender;
-(IBAction)stopBitsBtnAction:(id)sender;
-(IBAction)parityBtnAction:(id)sender;
-(IBAction)sendIntervalBtnAction:(id)sender;
-(IBAction)sendClearCmdBtnAction:(id)sender;

@property (unsafe_unretained) IBOutlet NSTextView *sendTextView;
@property (unsafe_unretained) IBOutlet NSButton *sendButton;
@property (unsafe_unretained) IBOutlet NSTextView *receivedDataTextView;
@property (unsafe_unretained) IBOutlet NSButton *openCloseButton;
@property (unsafe_unretained) IBOutlet NSPopUpButton *lineEndingPopUpButton;
@property (unsafe_unretained) IBOutlet NSButton *backBtn;
@property (unsafe_unretained) IBOutlet NSPopUpButton *portsBtn;
@property (unsafe_unretained) IBOutlet NSPopUpButton *baudBtn;
@property (unsafe_unretained) IBOutlet NSButton *sendIntervalBtn;
@property (unsafe_unretained) IBOutlet NSTextField *sendIntervalValField;
@property (unsafe_unretained) IBOutlet NSButton *sendClearCmdBtn;

@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;
@property (nonatomic, strong) ORSSerialPort *_Nullable serialPort;
@property (nonatomic, strong) NSArray *availableBaudRates;
@property (nonatomic) BOOL shouldAddLineEnding;
@property (nonatomic) BOOL showLogTimeFlag;
@property (nonatomic) BOOL intervalSendFlag;

@property (weak) id<SubViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
