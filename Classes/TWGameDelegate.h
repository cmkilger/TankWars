//
//  TWGameDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 12/11/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWPlayer;

@protocol TWGameDelegate <NSObject>

- (void) addPlayer:(TWPlayer *)player;
- (void) playerConnected:(TWPlayer *)player;
- (void) removePlayer:(TWPlayer *)player;
- (void) updateView;
- (void) start;

@end
