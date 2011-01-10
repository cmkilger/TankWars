//
//  TWHostGame.m
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWGame.h"
#import "TWCollisionTypes.h"
#import "TWPlayer.h"
#import "TWBullet.h"
#import "TWServer.h"
#import "TWConnection.h"
#import "chipmunk.h"


@interface TWGame ()

@property (nonatomic, retain) TWServer * server;
@property (nonatomic, assign) CGSize arenaSize;
@property (nonatomic, retain) NSMutableArray * connectingPlayers;
@property (nonatomic, retain) NSDate * lastUpdate;

// Chipmunk Objects
@property (nonatomic, assign) cpSpace * space;
@property (nonatomic, assign) cpBody * walls;

- (void) update:(NSTimer *)timer;

int collWallBullet(cpArbiter * arb, struct cpSpace * space, void * data);
int collTankBullet(cpArbiter * arb, struct cpSpace * space, void * data);
int collBulletBullet(cpArbiter * arb, struct cpSpace * space, void * data);
void postTank(cpSpace *space, void *key, void *data);
void postBullet(cpSpace *space, void *key, void *data);

@end


@implementation TWGame

- (id) init {
	if (!(self = [super init]))
		return nil;
	
	self.arenaSize = CGSizeMake(960, 640);
	self.localPlayer = [[[TWPlayer alloc] initWithName:NSFullUserName()] autorelease];
	self.remotePlayers = [NSMutableArray array];
	self.connectingPlayers = [NSMutableArray array];
	
	NSError * error = nil;
	self.server = [[[TWServer alloc] initWithError:&error] autorelease];
	server.delegate = self;
	if (error) {
		NSLog(@"ERROR: %@", [error localizedDescription]);
		[self release];
		return nil;
	}
		
	return self;
}

#pragma mark -
#pragma mark Recieve connections

- (void) server:(TWServer *)server didMakeConnection:(TWConnection *)connection {
	TWPlayer * player = [[TWPlayer alloc] initWithConnection:connection];
	connection.delegate = player;
	player.game = self;
	[connectingPlayers addObject:player];
	[player release];
}

- (void) playerDidLoad:(TWPlayer *)player {
	[remotePlayers addObject:player];
	[connectingPlayers removeObject:player];
}

#pragma mark -
#pragma mark Accessors

- (void) setSpace:(cpSpace *)newSpace {
	if (space) {
		cpSpaceFreeChildren(space);
		cpSpaceFree(space);
	}
	space = newSpace;
}

- (void) setWalls:(cpBody *)newWalls {
	if (walls)
		cpBodyFree(walls);
	walls = newWalls;
}

- (NSArray *) allPlayers {
	return [remotePlayers arrayByAddingObject:localPlayer];
}

#pragma mark -
#pragma mark Gameplay

- (void) cancel {
	[server stop];
}

- (void) start {
	self.space = cpSpaceNew();
	space->gravity = cpvzero;
	
	cpSpaceAddCollisionHandler(space, TWCollisionTypeWall, TWCollisionTypeBullet, &collWallBullet, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, TWCollisionTypeTank, TWCollisionTypeBullet, &collTankBullet, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, TWCollisionTypeBullet, TWCollisionTypeBullet, &collBulletBullet, NULL, NULL, NULL, self);
	
	self.walls = cpBodyNew(INFINITY, INFINITY);
	
	cpVect corners[4] = {
		{0, 0},
		{0, 640},
		{960, 640},
		{960, 0},
	};
	
	cpVect a = corners[0];
	for (int i = 1; i < 5; i++) {
		cpVect b = corners[i%4];
		cpShape * seg = cpSegmentShapeNew(walls, a, b, 1.0);
		cpSpaceAddStaticShape(space, seg);
		seg->collision_type = TWCollisionTypeWall;
		a = b;
	}
	
	NSArray * players = [remotePlayers arrayByAddingObject:localPlayer];
	for (TWPlayer * player in players) {
		[player addToSpace:space ofSize:arenaSize];
	}
	
	self.lastUpdate = [NSDate date];
	[NSTimer scheduledTimerWithTimeInterval:1/60.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

- (void) update:(NSTimer *)timer {
	NSDate * date = [NSDate date];
	NSTimeInterval dt = [date timeIntervalSinceDate:lastUpdate];
	self.lastUpdate = date;
	
	int steps = 3;
	dt /= steps;
	
	for (int i = 0; i < steps; i++) {
		NSArray * players = [remotePlayers arrayByAddingObject:localPlayer];
		for (TWPlayer * player in players) {
			[player update:dt];
		}
		
		cpSpaceStep(space, dt);
	}
	
	// TODO: Send data to remote players.
	
	[delegate updateView];
}

int collWallBullet(cpArbiter * arb, struct cpSpace * space, void * data) {
	cpShape *a, *b;
	cpArbiterGetShapes(arb, &a, &b);
	TWBullet * bullet = (TWBullet *)b->data;
	bullet.destroyed = YES;
	cpSpaceAddPostStepCallback(space, &postBullet, b, bullet);
	return NO;
}

int collTankBullet(cpArbiter * arb, struct cpSpace * space, void * data) {
	cpShape *a, *b;
	cpArbiterGetShapes(arb, &a, &b);
	TWPlayer * player = (TWPlayer *)a->data;
	TWBullet * bullet = (TWBullet *)b->data;
	bullet.destroyed = YES;
	cpSpaceAddPostStepCallback(space, &postTank, a, player);
	cpSpaceAddPostStepCallback(space, &postBullet, b, bullet);
	return NO;
}

int collBulletBullet(cpArbiter * arb, struct cpSpace * space, void * data) {
	cpShape *a, *b;
	cpArbiterGetShapes(arb, &a, &b);
	TWBullet * bullet1 = (TWBullet *)a->data;
	TWBullet * bullet2 = (TWBullet *)b->data;
	bullet1.destroyed = YES;
	bullet2.destroyed = YES;
	cpSpaceAddPostStepCallback(space, &postBullet, a, bullet1);
	cpSpaceAddPostStepCallback(space, &postBullet, b, bullet2);
	return NO;
}

void postTank(cpSpace *space, void *key, void *data) {
	TWPlayer * player = data;
	[player hit];
}

void postBullet(cpSpace *space, void *key, void *data) {
	TWBullet * bullet = data;
	[bullet removeFromSpace:space];
}

@end
