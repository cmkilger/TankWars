//
//  TWBullet.m
//  TankWars
//
//  Created by Cory Kilger on 1/9/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWBullet.h"
#import "TWCollisionTypes.h"


@interface TWBullet ()

@property (nonatomic, assign) cpBody * body;
@property (nonatomic, assign) cpShape * shape;

@end


@implementation TWBullet

- (id) initWithSpace:(cpSpace *)space; {
	if (![super init])
		return nil;
	
	self.radius = 5.0;
	self.body = cpSpaceAddBody(space, cpBodyNew(radius, INFINITY));
	self.shape = cpSpaceAddShape(space, cpCircleShapeNew(body, radius, cpvzero));
	shape->collision_type = TWCollisionTypeBullet;
	shape->data = self;
	
	return self;
}

- (void) dealloc {
	if (body)
		cpBodyFree(body);
	if (shape)
		cpShapeFree(shape);
	[super dealloc];
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
	// TODO: 
}

- (void) removeFromSpace:(cpSpace *)space {
	if (body)
		cpSpaceRemoveBody(space, body);
	if (shape)
		cpSpaceRemoveShape(space, shape);
}

@end
