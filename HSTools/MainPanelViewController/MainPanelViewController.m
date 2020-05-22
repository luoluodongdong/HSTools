//
//  MainPanelViewController.m
//  TCPSocketTool
//
//  Created by WeidongCao on 2020/5/15.
//  Copyright © 2020 WeidongCao. All rights reserved.
//

#import "MainPanelViewController.h"
#import "CNGridViewItem.h"
#import "CNGridViewItemLayout.h"
#import "PublicDefines.h"

#define SOCKET_CLIENT_INDEX     0
#define SOCKET_SERVER_INDEX     1
#define SFC_QUERY_INDEX         2
#define SERIALPORT_INDEX        3
#define ZMQPUBLISH_INDEX        4
#define ZMQSUBSCRIBE_INDEX      5
#define ZMQRPCCLIENT_INDEX      6
#define ZMQRPCSERVER_INDEX      7



static NSString *kContentTitleKey, *kContentImageKey, *kItemSizeSliderPositionKey;
@interface MainPanelViewController ()

@property (strong) CNGridViewItemLayout *defaultLayout;
@property (strong) CNGridViewItemLayout *hoverLayout;
@property (strong) CNGridViewItemLayout *selectionLayout;
@property (strong) NSMutableArray *items;
@end

@implementation MainPanelViewController

+ (void)initialize {
    kContentTitleKey = @"itemTitle";
    kContentImageKey = @"itemImage";
    kItemSizeSliderPositionKey = @"ItemSizeSliderPosition";
}

- (id)init {
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _defaultLayout = [CNGridViewItemLayout defaultLayout];
        _hoverLayout = [CNGridViewItemLayout defaultLayout];
        _selectionLayout = [CNGridViewItemLayout defaultLayout];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.hoverLayout.backgroundColor = [[NSColor grayColor] colorWithAlphaComponent:0.42];
    self.selectionLayout.backgroundColor = [NSColor colorWithCalibratedRed:0.542 green:0.699 blue:0.807 alpha:0.420];

    /// insert some content
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"socketclient"], kContentImageKey,
                            @"Socket Client", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"socketserver"], kContentImageKey,
                            @"Socket Server", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"sfcquery"], kContentImageKey,
                            @"SFC Query", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"serialport"], kContentImageKey,
                            @"Serial Port", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"zmqpulish"], kContentImageKey,
                            @"ZMQ Publisher", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"zmqsubscribe"], kContentImageKey,
                            @"ZMQ Subscribe", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"zmqrpcclient"], kContentImageKey,
                            @"ZMQ RPC Client", kContentTitleKey,
                            nil]];
    [self.items addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSImage imageNamed:@"zmqrpcserver"], kContentImageKey,
                            @"ZMQ RPC Server", kContentTitleKey,
                            nil]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:kItemSizeSliderPositionKey]) {
       // self.itemSizeSlider.integerValue = [defaults integerForKey:kItemSizeSliderPositionKey];
    }
    self.gridView.itemSize = NSMakeSize(200, 180);
    //self.gridView.backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"BackgroundDust"]];
    self.gridView.backgroundColor = [NSColor clearColor];
    self.gridView.scrollElasticity = YES;
    [self.gridView reloadData];
}

-(IBAction)clientBtnAction:(id)sender{
    
}
-(IBAction)serverBtnAction:(id)sender{
    
}

#pragma mark - CNGridView DataSource

- (NSUInteger)gridView:(CNGridView *)gridView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (CNGridViewItem *)gridView:(CNGridView *)gridView itemAtIndex:(NSInteger)index inSection:(NSInteger)section {
    static NSString *reuseIdentifier = @"CNGridViewItem";

    CNGridViewItem *item = [gridView dequeueReusableItemWithIdentifier:reuseIdentifier];
    if (item == nil) {
        item = [[CNGridViewItem alloc] initWithLayout:self.defaultLayout reuseIdentifier:reuseIdentifier];
    }
    item.hoverLayout = self.hoverLayout;
    item.selectionLayout = self.selectionLayout;

    NSDictionary *contentDict = [self.items objectAtIndex:index];
    item.itemTitle = [contentDict objectForKey:kContentTitleKey]; // [NSString stringWithFormat:@"Item: %lu", index];
    item.itemImage = [contentDict objectForKey:kContentImageKey];

    return item;
}

#pragma mark - NSNotifications

//- (void)detectedNotification:(NSNotification *)notif {
//    //    CNLog(@"notification: %@", notif);
//}

#pragma mark - CNGridView Delegate

- (void)gridView:(CNGridView *)gridView didClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
    CNLog(@"didClickItemAtIndex: %li", index);
    if (index == SOCKET_CLIENT_INDEX) { //socket client
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"socketclient"}];
        }
    }
    else if(index  == SOCKET_SERVER_INDEX){ //socket server
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"socketserver"}];
        }
    }
    else if(index == SFC_QUERY_INDEX){ //sfc query
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"sfcquery"}];
        }
    }
    else if(index == SERIALPORT_INDEX){ //serialport
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"serialport"}];
        }
    }
    else if(index == ZMQPUBLISH_INDEX){ //serialport
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"zmqpublish"}];
        }
    }
    else if(index == ZMQSUBSCRIBE_INDEX){ //serialport
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"zmqsubscribe"}];
        }
    }
    else if(index == ZMQRPCCLIENT_INDEX){ //serialport
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"zmqrpcclient"}];
        }
    }
    else if(index == ZMQRPCSERVER_INDEX){ //serialport
        if ([self.delegate respondsToSelector:@selector(eventFromSubViewController:)]) {
            [self.delegate eventFromSubViewController:@{@"name":@"panel",@"data":@"zmqrpcserver"}];
        }
    }
}
//
//- (void)gridView:(CNGridView *)gridView didDoubleClickItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
//    CNLog(@"didDoubleClickItemAtIndex: %li", index);
//
//}
//
//- (void)gridView:(CNGridView *)gridView didActivateContextMenuWithIndexes:(NSIndexSet *)indexSet inSection:(NSUInteger)section {
//    CNLog(@"rightMouseButtonClickedOnItemAtIndex: %@", indexSet);
//}

//- (void)gridView:(CNGridView *)gridView didSelectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
//    CNLog(@"didSelectItemAtIndex: %li", index);
//}

//- (void)gridView:(CNGridView *)gridView didDeselectItemAtIndex:(NSUInteger)index inSection:(NSUInteger)section {
//    CNLog(@"didDeselectItemAtIndex: %li", index);
//
//}

@end
