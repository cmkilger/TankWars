//
//  TWIOSAppDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWIOSGameViewController;

@interface TWIOSAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow * window;
	TWIOSGameViewController * gameViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow * window;
@property (nonatomic, retain) IBOutlet TWIOSGameViewController * gameViewController;

@end
