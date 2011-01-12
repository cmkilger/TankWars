//
//  TWIOSAppDelegate.m
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWIOSAppDelegate.h"
#import "TWIOSGameViewController.h"

@implementation TWIOSAppDelegate

@synthesize window;
@synthesize gameViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[window addSubview:gameViewController.view];
	[window makeKeyAndVisible];
	
	return YES;
}

- (void) dealloc {
	[gameViewController release];
	[window release];
	[super dealloc];
}

@end
