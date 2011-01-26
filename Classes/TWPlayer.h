//
//  TWPlayer.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWConnectionDelegate.h"
#import "chipmunk.h"

typedef enum {			
	TWPlayerPacketTypeName = 4,
	TWPlayerPacketTypeLocation = 5,
} TWPlayerPacketType;

@class TWGame;
@class TWConnection;

@interface TWPlayer : NSObject <TWConnectionDelegate>

@property (nonatomic, assign) BOOL firing;
@property (nonatomic, assign) BOOL movingForward;
@property (nonatomic, assign) BOOL movingBackward;
@property (nonatomic, assign) BOOL turningLeft;
@property (nonatomic, assign) BOOL turningRight;

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;

@property (nonatomic, assign) TWGame * game;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, retain) NSMutableArray * bullets;

@property (nonatomic, retain) TWConnection * connection;

@property (nonatomic, retain) NSData * playerUUID;
@property (nonatomic, retain) NSData * playerName;
@property (nonatomic, retain) NSData * playerLocation;
@property (nonatomic, retain) NSDictionary * playerInfo;

- (id) initWithName:(NSString *)name;
- (id) initWithConnection:(TWConnection *)connection;
- (void) addToSpace:(cpSpace *)space ofSize:(CGSize)size;
- (void) update:(NSTimeInterval)dt;
- (void) hit;


@end
