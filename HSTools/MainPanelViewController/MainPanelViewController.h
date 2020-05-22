//
//  MainPanelViewController.h
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SubViewControllerProtocol.h"
#import "CNGridView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainPanelViewController : NSViewController<CNGridViewDataSource, CNGridViewDelegate>
{
    IBOutlet NSButton *clientBtn;
    IBOutlet NSButton *serverBtn;
    
}
@property (strong) IBOutlet CNGridView *gridView;

@property (weak) id<SubViewControllerDelegate> delegate;
-(IBAction)clientBtnAction:(id)sender;
-(IBAction)serverBtnAction:(id)sender;

@end

NS_ASSUME_NONNULL_END
