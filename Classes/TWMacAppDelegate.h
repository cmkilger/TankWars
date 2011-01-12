//
//  TWMacAppDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TWGameDelegate.h"
#import "TWBrowserDelegate.h"

@class TWPlayer, TWMacGameView;

@interface TWMacAppDelegate : NSObject <NSApplicationDelegate, TWGameDelegate, TWBrowserDelegate>

@property (retain) IBOutlet NSWindow * window;
@property (retain) IBOutlet NSWindow * connectingSheet;
@property (retain) IBOutlet NSWindow * gameWindow;
@property (retain) IBOutlet NSCollectionView * collectionView;
@property (retain) IBOutlet NSMutableArray * playerItems;
@property (retain) IBOutlet TWMacGameView * view;

- (IBAction) createGame:(id)sender;
- (IBAction) joinGame:(id)sender;

- (IBAction) didSelectCancel:(id)sender;
- (IBAction) didSelectStart:(id)sender;

@end
