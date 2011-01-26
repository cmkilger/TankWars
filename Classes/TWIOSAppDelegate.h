//
//  TWIOSAppDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWGameDelegate.h"
#import "TWBrowserDelegate.h"

@class TWGame;
@class TWBrowser;
@class TWIOSGameViewController;
@class TWIOSNewGameViewController;

@interface TWIOSAppDelegate : NSObject <UIApplicationDelegate, TWGameDelegate, TWBrowserDelegate>

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet TWIOSGameViewController * gameViewController;
@property (nonatomic, retain) IBOutlet TWIOSNewGameViewController * newGameViewController;

@property (nonatomic, retain) TWGame * game;
@property (nonatomic, retain) TWBrowser * browser;
@property (nonatomic, retain) NSMutableArray * players;
@property (nonatomic, assign) UITableView * connectingTable;

@end
