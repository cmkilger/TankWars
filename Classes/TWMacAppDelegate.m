//
//  TWMacAppDelegate.m
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWMacAppDelegate.h"
#import "TWMacPlayerItem.h"
#import "TWMacGameView.h"
#import "TWPlayer.h"
#import "TWGame.h"
#import "chipmunk.h"

#define kCancelReturnCode 1000
#define kStartReturnCode 2000

@interface TWMacAppDelegate ()

@property (nonatomic, retain) TWGame * game;

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
	self.game = [[[TWGame alloc] init] autorelease];
	game.delegate = self;
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
			[playerItems removeObject:item];
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

- (void) updateView {
	view.game = game; // TODO: get rid of this line
	[view setNeedsDisplay:YES];
}

#pragma mark -

- (IBAction) didSelectCancel:(id)sender {
	[[NSApplication sharedApplication] endSheet:connectingSheet returnCode:kCancelReturnCode];
	[game cancel];
	self.game = nil;
}

- (IBAction) didSelectStart:(id)sender {
	[[NSApplication sharedApplication] endSheet:connectingSheet returnCode:kStartReturnCode];
	[game start];
}

- (void) start {
	[self didSelectStart:self];
}

#pragma mark -

- (void)windowWillClose:(NSNotification *)notification {
	NSWindow * theWindow = [notification object];
	if (theWindow == gameWindow) {
		// TODO: 
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
