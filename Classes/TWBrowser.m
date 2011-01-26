//
//  TWBonjourBrowser.m
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWBrowser.h"
#import "TWConnection.h"

@interface TWBrowser ()

@property (nonatomic, retain) NSNetServiceBrowser * serviceBrowser;
@property (nonatomic, retain) NSNetService * service;
@property (nonatomic, retain) NSInputStream * inputStream;
@property (nonatomic, retain) NSOutputStream * outputStream;

@end


@implementation TWBrowser

- (id)initWithType:(NSString *)type domain:(NSString *)domain {
    if ((self = [super init])) {
		self.serviceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
		[self.serviceBrowser setDelegate:self];
		[self.serviceBrowser searchForServicesOfType:type inDomain:domain];
    }
    return self;
}

#pragma mark -
#pragma mark Net Services delegate methods

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	[delegate browser:self didRemoveService:aNetService];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	[delegate browser:self didFindService:aNetService];
}

- (void) netServiceDidResolveAddress:(NSNetService *)sender {
	TWConnection * connection = [[TWConnection alloc] initWithService:sender];
	[delegate browser:self didMakeConnection:connection];
	[connection release];
}

- (void) netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	NSLog(@"did not resolve %@ %@", sender, errorDict);
	[delegate browser:self didNotResolveService:sender errorDict:errorDict];
}

#pragma mark -
#pragma mark Table view delegate

- (void) resolveService:(NSNetService *)aNetService {
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:30.0];
	NSLog(@"Resolving...");
}

- (void)dealloc {
    [super dealloc];
}

@end

