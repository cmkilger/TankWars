//
//  TWPlayerItem.h
//  TankWars
//
//  Created by Cory Kilger on 12/11/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWPlayer;

@interface TWMacPlayerItem : NSObject

@property (nonatomic, retain) TWPlayer * player;
@property (nonatomic, assign) BOOL connected;

@end