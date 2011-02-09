//
//  TWIOSAppDelegate.m
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWIOSAppDelegate.h"
#import "TWIOSGameViewController.h"
#import "TWIOSNewGameViewController.h"
#import "TWGame.h"

@implementation TWIOSAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[window addSubview:gameViewController.view];
	[window makeKeyAndVisible];
	
	UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:newGameViewController];
	[gameViewController presentModalViewController:navigationController animated:YES];
	[navigationController release];
}

- (void) dealloc {
	[newGameViewController release];
	[gameViewController release];
	[window release];
	[super dealloc];
}

#pragma mark -

- (void) addPlayer:(TWPlayer *)player {
	[players addObject:player];
	[connectingTable reloadData];
}

- (void) playerConnected:(TWPlayer *)player {
	[connectingTable reloadData];
}

- (void) removePlayer:(TWPlayer *)player {
	[players removeObject:player];
	[connectingTable reloadData];
}

- (void) updateView {
	[gameViewController update];
}

#pragma mark -

- (void) browser:(TWBrowser *)browser didFindService:(NSNetService *)service {
	[players addObject:service];
	[connectingTable reloadData];
}

- (void) browser:(TWBrowser *)browser didRemoveService:(NSNetService *)service {
	[players removeObject:service];
	[connectingTable reloadData];
}

- (void) browser:(TWBrowser *)browser didMakeConnection:(TWConnection *)connection {
	// TODO: start game
	[gameViewController dismissModalViewControllerAnimated:YES];
	self.game = [[[TWGame alloc] initWithConnection:connection] autorelease];
	game.delegate = self;
	[game start];
	gameViewController.game = game;
}

- (void) browser:(TWBrowser *)browser didNotResolveService:(NSNetService *)service errorDict:(NSDictionary *)errorDict {
	// TODO: 
}

@end
