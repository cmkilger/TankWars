//
//  TWIOSGameView.h
//  TankWars-iOS
//
//  Created by Cory Kilger on 1/13/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWGame;

@interface TWIOSGameView : UIView <UIAccelerometerDelegate>

@property (nonatomic, retain) TWGame * game;

@end
