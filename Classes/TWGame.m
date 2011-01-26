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

@interface TWGame ()

@property (nonatomic, retain) TWServer * server;
@property (nonatomic, retain) TWConnection * connection;
@property (nonatomic, retain) NSMutableData * savedData;
@property (nonatomic, assign) CGSize arenaSize;
@property (nonatomic, retain) NSMutableArray * connectingPlayers;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSData * playersData;

// Chipmunk Objects
@property (nonatomic, assign) cpSpace * space;
@property (nonatomic, assign) cpBody * walls;

- (void) update:(NSTimer *)timer;
- (void) addPlayer:(NSData *)data;
- (NSData *) playerDataForPlayer:(TWPlayer *)player;
- (void) removePlayer:(NSData *)data;

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
	
	NSError * error = nil;
	self.server = [[[TWServer alloc] initWithError:&error] autorelease];
	server.delegate = self;
	if (error) {
		NSLog(@"ERROR: %@", [error localizedDescription]);
		[self release];
		return nil;
	}
	
	self.connectingPlayers = [NSMutableArray array];
	self.savedData = [NSMutableData data];
		
	return self;
}

- (id) initWithConnection:(TWConnection *)newConnection {
	if (!(self = [super init]))
		return nil;
	
	self.arenaSize = CGSizeMake(960, 640);
	self.localPlayer = [[[TWPlayer alloc] initWithName:NSFullUserName()] autorelease];
	self.remotePlayers = [NSMutableArray array];
	
	self.connection = newConnection;
	connection.delegate = self;
	
	self.savedData = [NSMutableData data];
	
	return self;
}

- (void) dealloc {
	[server stop];
	[server release];
	[connectingPlayers release];
	[lastUpdate release];
	
	if (space) {
		cpSpaceFreeChildren(space);
		cpSpaceFree(space);
	}
	
	if (walls) {
		cpBodyFree(walls);
	}
	
	[super dealloc];
}

#pragma mark -
#pragma mark Recieve connections

- (void) server:(TWServer *)server didMakeConnection:(TWConnection *)newConnection {
	TWPlayer * player = [[TWPlayer alloc] initWithConnection:newConnection];
	player.game = self;
	[connectingPlayers addObject:player];
	[delegate addPlayer:player];
	[player release];
}

- (void) playerDidLoad:(TWPlayer *)player {
	[remotePlayers addObject:player];
	[connectingPlayers removeObject:player];
	[delegate playerConnected:player];
	if (space)
		[player addToSpace:space ofSize:arenaSize];
	[player.connection sendData:[self playerDataForPlayer:localPlayer]];
	for (TWPlayer * remotePlayer in remotePlayers) {
		if (player != remotePlayer) {
			[remotePlayer.connection sendData:[self playerDataForPlayer:player]];
			[player.connection sendData:[self playerDataForPlayer:remotePlayer]];
		}
	}
}

- (void) playerDidDisconnect:(TWPlayer *)player {
	// ???: should we remove the tank from the arena?
	[delegate removePlayer:player];
}

#pragma mark -
#pragma mark Connection stuff

// !!!: This can be done in the presentation
// This data is received from the server.  If we are the server this is never used.
- (void) connection:(TWConnection *)aConnection didReceiveData:(NSData *)data {
	[savedData appendData:data];
	
	NSUInteger index = 0;
	NSUInteger length = [savedData length];
	uint8_t * bytes = (uint8_t *) [savedData bytes];
	
	NSUInteger packetIndex;
	
	while (index < length) {
		packetIndex = index;
		
		uint8_t type = bytes[index++];
		
		UInt32 size;
		if (index+sizeof(UInt32) > length)
			goto FAILED;
		memcpy(&size, &(bytes[index]), sizeof(UInt32));
		size = CFSwapInt32BigToHost(size);
		index += sizeof(UInt32);
		
		if (index+size > length)
			goto FAILED;
		NSData * content = [NSData dataWithBytes:&(bytes[index]) length:size];
		index += [content length];
		
		switch (type) {
			case TWGamePacketTypeAll: {
				[self setPlayersData:content];
			} break;
				
			case TWGamePacketTypeUUID: {
				localPlayer.playerUUID = content;
				NSLog(@"UUID: %@", localPlayer.uuid);
				[connection sendData:[localPlayer playerName]];
			} break;
				
			case TWGamePacketTypeAddPlayer: {
				[self addPlayer:content];
			} break;
				
			case TWGamePacketTypeRemovePlayer: {
				[self removePlayer:content];
			} break;
				
			default:
				NSLog(@"ERROR: Unknown packet type %d.", type);
		}
	}
	
	[savedData replaceBytesInRange:NSMakeRange(0, [savedData length]) withBytes:NULL length:0];
	
	return;
	
FAILED:
	if (packetIndex < length)
		[savedData replaceBytesInRange:NSMakeRange(0, packetIndex) withBytes:NULL length:0];
}

- (void) connectionDidEnd:(TWConnection *)connection {
	// TODO: we were disconnected from the server
}

#pragma mark -
#pragma mark Connection data handling

- (void) addPlayer:(NSData *)data {
	NSDictionary * playerDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	TWPlayer * player = [[TWPlayer alloc] initWithName:[playerDict objectForKey:@"name"]];
	player.uuid = [playerDict objectForKey:@"uuid"];
	[self playerDidLoad:player];
	[player release];
}

- (NSData *) playerDataForPlayer:(TWPlayer *)player {
	UInt8 type = TWGamePacketTypeAddPlayer;
	
	NSMutableDictionary * playerDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
										player.uuid, @"uuid",
										player.name, @"name",
										 nil];
	NSData * content = [NSKeyedArchiver archivedDataWithRootObject:playerDict];
	
	UInt32 length = [content length];
	UInt32 size = CFSwapInt32HostToBig(length);
	NSMutableData * data = [NSMutableData data];
	[data appendBytes:&type length:sizeof(UInt8)];
	[data appendBytes:&size length:sizeof(UInt32)];
	[data appendData:content];
	return data;
}

#pragma mark -

- (void) removePlayer:(NSData *)data {
	// TODO: 
}

#pragma mark -

- (NSData *) playersData {
	NSArray * players = [remotePlayers arrayByAddingObject:localPlayer];
	UInt8 type = TWGamePacketTypeAll;
	
	NSMutableDictionary * playersDict = [NSMutableDictionary dictionary];
	for (TWPlayer * player in players)
		[playersDict setObject:player.playerInfo forKey:player.uuid];
	NSData * content = [NSKeyedArchiver archivedDataWithRootObject:playersDict];
	
	UInt32 length = [content length];
	UInt32 size = CFSwapInt32HostToBig(length);
	NSMutableData * data = [NSMutableData data];
	[data appendBytes:&type length:sizeof(UInt8)];
	[data appendBytes:&size length:sizeof(UInt32)];
	[data appendData:content];
	return data;
}

- (void) setPlayersData:(NSData *)data {
	NSDictionary * playersDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	NSArray * players = [remotePlayers arrayByAddingObject:localPlayer];
	for (TWPlayer * player in players)
		player.playerInfo = [playersDict objectForKey:player.uuid];
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
	[server stop];
	self.server = nil;
	
	self.space = cpSpaceNew();
	space->gravity = cpvzero;
	
	cpSpaceAddCollisionHandler(space, TWCollisionTypeWall, TWCollisionTypeBullet, &collWallBullet, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, TWCollisionTypeTank, TWCollisionTypeBullet, &collTankBullet, NULL, NULL, NULL, self);
	cpSpaceAddCollisionHandler(space, TWCollisionTypeBullet, TWCollisionTypeBullet, &collBulletBullet, NULL, NULL, NULL, self);
	
	self.walls = cpBodyNew(INFINITY, INFINITY);
	
	cpVect corners[4] = {
		{0, 0},
		{960, 0},
		{960, 640},
		{0, 640},
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
		// Update players
		NSArray * players = [remotePlayers arrayByAddingObject:localPlayer];
		for (TWPlayer * player in players) {
			[player update:dt];
		}
		
		// Update space
		cpSpaceStep(space, dt);
	}
	
	// Send data about all players to remote players if this is the server
	if (connection) {
		[connection sendData:localPlayer.playerLocation];
	}
	else {
		NSData * data = [self playersData];
		for (TWPlayer * remotePlayer in remotePlayers) {
			[remotePlayer.connection sendData:data];
		}
	}

	[delegate updateView];
}

#pragma mark -
#pragma mark Collision callbacks

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
