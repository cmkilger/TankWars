//
//  TWMacGameView.h
//  TankWars
//
//  Created by Cory Kilger on 12/11/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TWGame;

@interface TWMacGameView : NSView

@property (nonatomic, retain) TWGame * game;

@end
