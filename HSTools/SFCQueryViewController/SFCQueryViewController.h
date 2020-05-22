//
//  SFCQueryViewController.h
//  HSTools
//
//  Created by WeidongCao on 2020/5/16.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN;

@protocol NSControlTextEditingDelegate;

@interface SFCQueryViewController : NSViewController
{
    IBOutlet NSButton *backBtn;
    
    //url
    IBOutlet NSComboBox *urlComboBox;
    IBOutlet NSTextView *dataTextView;
    IBOutlet NSButton *queryBtn;
    
    IBOutlet NSButton *postBtn;
    IBOutlet NSButton *getBtn;
    IBOutlet NSButton *clearLogBtn;
    
    IBOutlet NSTextView *receivedTV;
    
}

@property (weak) id<SubViewControllerDelegate> delegate;
-(IBAction)backBtnAction:(id)sender;

-(IBAction)queryBtnAction:(id)sender;
-(IBAction)clearLogBtnAction:(id)sender;
-(IBAction)postOrGetBtnAction:(id)sender;
@end

NS_ASSUME_NONNULL_END
