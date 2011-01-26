//
//  TWMacAppDelegate.m
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWMacAppDelegate.h"
#import "TWBrowser.h"
#import "TWMacPlayerItem.h"
#import "TWMacGameView.h"
#import "TWPlayer.h"
#import "TWGame.h"
#import "chipmunk.h"

#define kCancelReturnCode 1000
#define kStartReturnCode 2000

@interface TWMacAppDelegate ()

@property (nonatomic, retain) TWGame * game;
@property (nonatomic, retain) TWBrowser * browser;

- (void) insertObject:(TWMacPlayerItem *)p inPlayerItemsAtIndex:(NSUInteger)index;
- (void) removeObjectFromPlayerItemsAtIndex:(NSUInteger)index;

@end


@implementation TWMacAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	cpInitChipmunk();
}

- (void)sheetDidEnd:(NSWindow *)aSheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[aSheet close];
	if (returnCode == kStartReturnCode) {
		[window close];
		[gameWindow makeKeyAndOrderFront:nil];
		[view becomeFirstResponder];
	}
	else {
		self.game = nil;
	}
}

#pragma mark -
#pragma mark New game

- (void) createGame:(id)sender {
	self.playerItems = [NSMutableArray array];
	self.game = [[[TWGame alloc] init] autorelease];
	game.delegate = self;
	[[NSApplication sharedApplication] beginSheet:connectingSheet
								   modalForWindow:window
									modalDelegate:self
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
									  contextInfo:nil];
}

- (void) joinGame:(id)sender {
	self.playerItems = [NSMutableArray array];
	self.browser = [[[TWBrowser alloc] initWithType:@"_tankwars._tcp." domain:@""] autorelease];
	browser.delegate = self;
	[[NSApplication sharedApplication] beginSheet:connectingSheet
								   modalForWindow:window
									modalDelegate:self
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
									  contextInfo:nil];
}

#pragma mark -

- (void) playerConnected:(TWPlayer *)player {
	TWMacPlayerItem * item = nil;
	for (TWMacPlayerItem * anItem in playerItems) {
		if (anItem.player == player) {
			item = anItem;
			break;
		}
	}
	if (!item) {
		item = [[[TWMacPlayerItem alloc] init] autorelease];
		item.player = player;
		[self insertObject:item inPlayerItemsAtIndex:[playerItems count]];
	}
	item.connected = YES;
}

- (void) removePlayer:(TWPlayer *)player {
	for (TWMacPlayerItem * item in playerItems) {
		if (item.player == player) {
			[self removeObjectFromPlayerItemsAtIndex:[playerItems indexOfObject:item]];
			break;
		}
	}
}

- (void) insertObject:(TWMacPlayerItem *)p inPlayerItemsAtIndex:(NSUInteger)index {
    [playerItems insertObject:p atIndex:index];
}

- (void) removeObjectFromPlayerItemsAtIndex:(NSUInteger)index {
    [playerItems removeObjectAtIndex:index];
}

- (void) addPlayer:(TWPlayer *)player {
	TWMacPlayerItem * item = [[[TWMacPlayerItem alloc] init] autorelease];
	[self insertObject:item inPlayerItemsAtIndex:[playerItems count]];
	item.connected = NO;
	item.player = player;
}

#pragma mark -

- (void) browser:(TWBrowser *)browser didFindService:(NSNetService *)service {
	TWMacPlayerItem * item = [[[TWMacPlayerItem alloc] init] autorelease];
	[self insertObject:item inPlayerItemsAtIndex:[playerItems count]];
	item.connected = YES;
	item.player = service;
}

- (void) browser:(TWBrowser *)browser didRemoveService:(NSNetService *)service {
	for (TWMacPlayerItem * item in playerItems) {
		if (item.player == service) {
			[playerItems removeObject:item];
			break;
		}
	}
}

- (void) browser:(TWBrowser *)browser didMakeConnection:(TWConnection *)connection {
	// TODO: start game
	self.game = [[[TWGame alloc] initWithConnection:connection] autorelease];
	game.delegate = self;
	[game start];
}

- (void) browser:(TWBrowser *)browser didNotResolveService:(NSNetService *)service errorDict:(NSDictionary *)errorDict {
	// TODO: 
	NSLog(@"%@", errorDict);
}

#pragma mark -

- (void) updateView {
	view.game = game; // TODO: get rid of this line somehow
	[view setNeedsDisplay:YES];
}

#pragma mark -

- (IBAction) didSelectCancel:(id)sender {
	[[NSApplication sharedApplication] endSheet:connectingSheet returnCode:kCancelReturnCode];
	[game cancel];
	self.game = nil;
}

- (IBAction) didSelectStart:(id)sender {
	if (browser) {
		NSLog(@"indexes: %@", [self.collectionView selectionIndexes]);
		TWMacPlayerItem * item = [playerItems objectAtIndex:[[self.collectionView selectionIndexes] lastIndex]];
		[browser resolveService:item.player];
	}
	else {
//		for (TWMacPlayerItem * item in playerItems)
//			[game playerDidLoad:item.player];
		[game start];
	}
	
	[[NSApplication sharedApplication] endSheet:connectingSheet returnCode:kStartReturnCode];
}

#pragma mark -

- (void)windowWillClose:(NSNotification *)notification {
	NSWindow * theWindow = [notification object];
	if (theWindow == gameWindow) {
		// TODO: show the start window
	}
}

#pragma mark -

- (void) dealloc {
	[playerItems release];
	[connectingSheet release];
	[gameWindow release];
	[window release];
	[super dealloc];
}

@end
