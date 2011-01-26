//
//  TWHostGame.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWServerDelegate.h"
#import "TWConnectionDelegate.h"
#import "TWGameDelegate.h"
#import "chipmunk.h"

typedef enum {
	TWGamePacketTypeAll = 0,
	TWGamePacketTypeAddPlayer = 1,
	TWGamePacketTypeRemovePlayer = 2,
	TWGamePacketTypeUUID = 3,
} TWGamePacketType;

@class TWPlayer;

@interface TWGame : NSObject <TWServerDelegate, TWConnectionDelegate>

@property (nonatomic, assign) id<TWGameDelegate> delegate;
@property (nonatomic, retain) TWPlayer * localPlayer;
@property (nonatomic, retain) NSMutableArray * remotePlayers;
@property (nonatomic, readonly) NSArray * allPlayers;

- (id) initWithConnection:(TWConnection *)newConnection;

- (void) playerDidLoad:(TWPlayer *)player;
- (void) playerDidDisconnect:(TWPlayer *)player;
- (void) cancel;
- (void) start;

@end
