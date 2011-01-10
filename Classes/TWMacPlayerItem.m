//
//  TWPlayerItem.m
//  TankWars
//
//  Created by Cory Kilger on 12/11/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWMacPlayerItem.h"
#import "TWPlayer.h"


@implementation TWMacPlayerItem

- (void) dealloc {
	[player release];
	[super dealloc];
}

@end
