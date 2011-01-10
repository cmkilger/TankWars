//
//  TWPlayer.m
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWPlayer.h"
#import "TWBullet.h"
#import "TWConnection.h"
#import "TWGame.h"
#import "TWCollisionTypes.h"

#define TURN_VEL 2.0
#define MAX_VEL 60.0
#define BULLET_VEL MAX_VEL*4.0
#define COOLDOWN 0.25;

typedef enum {
	TWPlayerPacketTypeIdentification,
} TWPlayerPacketType;


@interface TWPlayer ()

@property (nonatomic, retain) NSMutableData * savedData;
@property (nonatomic, assign) cpSpace * space;
@property (nonatomic, assign) cpBody * body;
@property (nonatomic, assign) cpShape * shape;
@property (nonatomic, assign) CGFloat cooldown;

@end


@implementation TWPlayer

- (id) initWithName:(NSString *)newName {
	if (!(self = [super init]))
		return nil;
	self.name = newName;
	self.bullets = [NSMutableArray array];
	return self;
}

- (id) initWithConnection:(TWConnection *)connection {
	if (!(self = [super init]))
		return nil;
	self.savedData = [NSMutableData data];
	return self;
}

- (void) dealloc {
	[name release];
	[bullets release];
	[savedData release];
	[super dealloc];
}

#pragma mark -

- (void) addToSpace:(cpSpace *)newSpace ofSize:(CGSize)size {
	self.space = newSpace;
	self.radius = 20.0;
	body = cpSpaceAddBody(space, cpBodyNew(radius, INFINITY));
	shape = cpSpaceAddShape(space, cpCircleShapeNew(body, radius, cpvzero));
	shape->collision_type = TWCollisionTypeTank;
	shape->data = self;
	self.location = CGPointMake((arc4random()%(int)(size.width-radius*3))+radius*1.5, (arc4random()%(int)(size.height-radius*3))+radius*1.5);
	self.rotation = ((arc4random()%360)/180.0-1.0)*M_PI;
}

#pragma mark -

- (CGPoint) location {
	cpVect loc = cpBodyGetPos(body);
	return CGPointMake(loc.x, loc.y);
}

- (void) setLocation:(CGPoint)loc {
	cpBodySetPos(body, cpv(loc.x, loc.y));
}

- (CGFloat) rotation {
	return cpvtoangle(cpBodyGetRot(body));
}

- (void) setRotation:(CGFloat)rot {
	cpBodySetAngle(body, rot);
}

- (CGFloat) velocity {
	return cpvlength(cpBodyGetVel(body));
}

- (void) setVelocity:(CGFloat)vel {
	cpBodySetVel(body, cpvmult(cpvnormalize_safe(cpBodyGetRot(body)), vel));
}

#pragma mark -

- (void) update:(NSTimeInterval)dt {
	// Rotation
	cpFloat dRot = 0.0;
	if (turningLeft)
		dRot += TURN_VEL*dt;
	if (turningRight)
		dRot -= TURN_VEL*dt;
	self.rotation += dRot;
	
	// Velocity
	cpFloat force = 0;
	if (movingForward)
		force += MAX_VEL;
	if (movingBackward)
		force -= MAX_VEL;
	self.velocity = force;
	
	// Firing
	cooldown -= dt;
	if (firing && cooldown <= 0.0) {
		cooldown = COOLDOWN;
		TWBullet * bullet = [[TWBullet alloc] initWithSpace:space];
		cpVect loc = cpvadd(cpBodyGetPos(body), cpvmult(cpvnormalize_safe(cpBodyGetRot(body)), radius*2.0));
		bullet.location = CGPointMake(loc.x, loc.y);
		bullet.rotation = self.rotation;
		bullet.velocity = BULLET_VEL;
		[bullets addObject:bullet];
		[bullet release];
	}
	
	// Update bullets
	for (TWBullet * bullet in [NSArray arrayWithArray:bullets]) {
		if (bullet.destroyed)
			[bullets removeObject:bullet];
	}
	for (TWBullet * bullet in bullets)
		[bullet update:dt];
}

- (void) hit {
	NSLog(@"%@ HIT!", self);
}

#pragma mark -

// !!!: This can be done in the presentation
- (void) connection:(TWConnection *)connection didReceiveData:(NSData *)data {
	[savedData appendData:data];
	
	NSUInteger index = 0;
	NSUInteger length = [savedData length];
	uint8_t * bytes = (uint8_t *) [savedData bytes];
	
	NSUInteger packetIndex;
	
	while (index < length) {
		packetIndex = index;
		
		uint8_t type = bytes[++index];
		
		UInt32 size;
		if (index+sizeof(NSUInteger) >= length)
			goto FAILED;
		memcpy(&size, &(bytes[index]), sizeof(NSUInteger));
		size = EndianU32_BtoN(size);
		index += sizeof(NSUInteger);
		
		if (index+size >= length)
			goto FAILED;
		NSData * content = [NSData dataWithBytes:&(bytes[index]) length:size];
		
		switch (type) {
			case TWPlayerPacketTypeIdentification: {
				self.name = [[[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding] autorelease];
				[game playerDidLoad:self];
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
	
}

@end
