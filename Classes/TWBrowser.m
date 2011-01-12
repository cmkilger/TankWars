//
//  TWBonjourBrowser.m
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWBrowser.h"

@implementation TWBrowser

@synthesize delegate;

- (id)initWithType:(NSString *)type domain:(NSString *)domain {
    if ((self = [super init])) {
		services = [[NSMutableArray alloc] init];
		serviceBrowser = [[NSNetServiceBrowser alloc] init];
		[serviceBrowser setDelegate:self];
		[serviceBrowser searchForServicesOfType:type inDomain:domain];
    }
    return self;
}

#pragma mark -
#pragma mark Net Services delegate methods

- (void) netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
	NSLog(@"will search...");
}

- (void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
	NSLog(@"stopped.");
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
	NSLog(@"%@", errorDict);
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
	NSLog(@"removed %@ - %d", domainString, moreComing);
}

-(void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	NSLog(@"removed %@ - %d", aNetService, moreComing);
	[services removeObject:aNetService];
	[delegate browser:self didRemoveService:aNetService];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
	NSLog(@"%@ - %d", domainString, moreComing);
}

- (void) netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	NSLog(@"Found %@%@", aNetService, moreComing?@", more coming":@"");
	NSLog(@"  addresses: %@", [aNetService addresses]);
	NSLog(@"  port: %d", (int)[aNetService port]);
	NSLog(@"  hostname: %@", [aNetService hostName]);
	NSLog(@"  type: %@", [aNetService type]);
	NSLog(@"  TXT: %@", [NSNetService dictionaryFromTXTRecordData:[aNetService TXTRecordData]]);
	
	[delegate browser:self didFindService:aNetService];
}

- (void) netServiceDidResolveAddress:(NSNetService *)sender {
	NSLog(@"Resolved %@", sender);
	NSLog(@"  addresses: %@", [sender addresses]);
	NSLog(@"  port: %d", (int)[sender port]);
	NSLog(@"  hostname: %@", [sender hostName]);
	NSLog(@"  type: %@", [sender type]);
	NSLog(@"  TXT: %@", [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]]);
	
	// ???: 
	if (![services containsObject:sender])
		[services addObject:sender];
	
	[delegate browser:self didResolveService:sender];
}

- (void) netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	NSLog(@"did not resolve %@ %@", sender, errorDict);
}

#pragma mark -
#pragma mark Table view delegate

- (void) resolveService:(NSNetService *)aNetService {
	
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:30.0];
	NSLog(@"Resolving...");
	
//	[service release];
//	service = [aNetService retain];
//	
//	if (![service getInputStream:&inputStream outputStream:&outputStream]) {
//		NSLog(@"ERROR: could not connect");
//		return;
//	}
//	
//	[inputStream setDelegate:self];
//	[outputStream setDelegate:self];
//	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
//	[inputStream open];
//	[outputStream open];
//	
//	NSLog(@"%@ %@", inputStream, outputStream);
}

- (void)dealloc {
    [super dealloc];
}

@end

