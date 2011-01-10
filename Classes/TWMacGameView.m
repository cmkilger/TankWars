//
//  TWMacGameView.m
//  TankWars
//
//  Created by Cory Kilger on 12/11/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWMacGameView.h"
#import "TWGame.h"
#import "TWPlayer.h"
#import "TWBullet.h"


@interface TWMacGameView ()

- (void) drawPlayer:(TWPlayer *)player withColor:(CGColorRef)color;

@end



@implementation TWMacGameView

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) keyDown:(NSEvent *)theEvent {
    unichar character = [[theEvent characters] characterAtIndex: 0];
	switch (character) {
		case ' ':
			game.localPlayer.firing = YES;
			break;
		case NSUpArrowFunctionKey:
			game.localPlayer.movingForward = YES;
			break;
		case NSDownArrowFunctionKey:
			game.localPlayer.movingBackward = YES;
			break;
		case NSRightArrowFunctionKey:
			game.localPlayer.turningRight = YES;
			break;
		case NSLeftArrowFunctionKey:
			game.localPlayer.turningLeft = YES;
			break;
		default:
			break;
	}
}

- (void) keyUp:(NSEvent *)theEvent {
    unichar character = [[theEvent characters] characterAtIndex: 0];
	switch (character) {
		case ' ':
			game.localPlayer.firing = NO;
			break;
		case NSUpArrowFunctionKey:
			game.localPlayer.movingForward = NO;
			break;
		case NSDownArrowFunctionKey:
			game.localPlayer.movingBackward = NO;
			break;
		case NSRightArrowFunctionKey:
			game.localPlayer.turningRight = NO;
			break;
		case NSLeftArrowFunctionKey:
			game.localPlayer.turningLeft = NO;
			break;
		default:
			break;
	}
}

#pragma mark =

static inline CGColorRef TWColorCreateWithPointer(void * ptr) {
	unsigned long val = (long)ptr;
	
	// hash the pointer up nicely
	val = (val+0x7ed55d16) + (val<<12);
	val = (val^0xc761c23c) ^ (val>>19);
	val = (val+0x165667b1) + (val<<5);
	val = (val+0xd3a2646c) ^ (val<<9);
	val = (val+0xfd7046c5) + (val<<3);
	val = (val^0xb55a4f09) ^ (val>>16);
	
	UInt8 r = (val>>0) & 0xFF;
	UInt8 g = (val>>8) & 0xFF;
	UInt8 b = (val>>16) & 0xFF;
	
	UInt8 max = r>g ? (r>b ? r : b) : (g>b ? g : b);
	
	const int mult = 127;
	const int add = 63;
	r = (r*mult)/max + add;
	g = (g*mult)/max + add;
	b = (b*mult)/max + add;
	
	return CGColorCreateGenericRGB(r/255.0, g/255.0, b/255.0, 1.0);
}

- (void)drawRect:(NSRect)dirtyRect {
	TWPlayer * localPlayer = game.localPlayer;
	CGColorRef randomColor = TWColorCreateWithPointer(localPlayer);
	[self drawPlayer:localPlayer withColor:randomColor];
	CGColorRelease(randomColor);
    
	for (TWPlayer * remotePlayer in game.remotePlayers) {
		CGColorRef redColor = CGColorCreateGenericRGB(1.0, 0.0, 0.0, 1.0);
		[self drawPlayer:remotePlayer withColor:redColor];
		CGColorRelease(redColor);
	}
}

- (void) drawPlayer:(TWPlayer *)player withColor:(CGColorRef)color {
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGContextSaveGState(context);
	
	CGPoint location = player.location;
	CGFloat rotation = player.rotation;
	CGFloat radius = player.radius;
		
	CGAffineTransform transform = CGAffineTransformMakeTranslation(location.x, location.y);
	transform = CGAffineTransformRotate(transform, rotation);
	CGContextConcatCTM(context, transform);
	
	CGColorRef blackColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
	
	CGContextSetFillColorWithColor(context, blackColor);
	CGContextAddRect(context, CGRectMake(-radius, -radius, radius*2, radius*2));
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, blackColor);
	CGContextAddRect(context, CGRectMake(0, -(radius/3), radius*2, radius/1.5));
	CGContextFillPath(context);
	
	CGContextSetFillColorWithColor(context, color);
	CGContextAddArc(context, 0, 0, radius/1.25, -M_PI, M_PI, 0);
	CGContextFillPath(context);
	
	CGColorRelease(blackColor);
	
	CGContextRestoreGState(context);
	
	CGContextSetFillColorWithColor(context, color);
	for (TWBullet * bullet in player.bullets) {
		if (bullet.destroyed)
			continue;
		CGPoint location = bullet.location;
		CGContextAddArc(context, location.x, location.y, bullet.radius, -M_PI, M_PI, 0);
		CGContextFillPath(context);
	}
}

@end
