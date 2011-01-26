//
//  TWBullet.h
//  TankWars
//
//  Created by Cory Kilger on 1/9/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "chipmunk.h"


@interface TWBullet : NSObject

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, assign) CGFloat rotation;
@property (nonatomic, assign) CGFloat velocity;
@property (nonatomic, assign) BOOL destroyed;
@property (nonatomic, assign) NSUInteger identifier;
<<<<<<< HEAD
@property (nonatomic, retain) NSDictionary * bulletInfo;
=======
>>>>>>> e5d65e7f74c9942d5449891b9634d85a56b26317

- (id) initWithSpace:(cpSpace *)space;
- (void) update:(NSTimeInterval)dt;
- (void) removeFromSpace:(cpSpace *)space;

@end
