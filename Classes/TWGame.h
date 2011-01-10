//
//  TWHostGame.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWServerDelegate.h"
#import "TWGameDelegate.h"
#import "chipmunk.h"

@class TWPlayer;

@interface TWGame : NSObject <TWServerDelegate>

@property (nonatomic, assign) id<TWGameDelegate> delegate;
@property (nonatomic, retain) TWPlayer * localPlayer;
@property (nonatomic, retain) NSMutableArray * remotePlayers;
@property (nonatomic, readonly) NSArray * allPlayers;

- (void) playerDidLoad:(TWPlayer *)player;
- (void) cancel;
- (void) start;

@end
