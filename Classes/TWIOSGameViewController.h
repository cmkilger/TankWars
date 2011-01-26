//
//  TWGameViewController.h
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TWIOSGameView;
@class TWGame;

@interface TWIOSGameViewController : UIViewController

@property (nonatomic, retain) IBOutlet TWIOSGameView * gameView;
@property (nonatomic, retain) TWGame * game;

- (void) update;

@end
