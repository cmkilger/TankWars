//
//  TWServer.m
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWServer.h"
#import "TWConnection.h"

NSString * const TWServerErrorDomain = @"com.corykilger.tankwars.ServerError";
NSString * const TWNetServiceType = @"_tankwars._tcp.";

@interface TWServer ()

@property (nonatomic, assign) CFSocketRef socket;
@property (nonatomic, retain) NSNetService * service;

- (BOOL) startServerWithError:(NSError **)error;
- (void) publishService;
- (void) acceptConnectionWithNativeHandle:(CFSocketNativeHandle)handle;

@end


@implementation TWServer

- (id) initWithError:(NSError **)error {
	if (!(self = [super init]))
		return nil;
	
	if (![self startServerWithError:error]) {
		[self release];
		return nil;
	}
	
	[self publishService];
	
	return self;
}

- (void) dealloc {
	if (socket) {
		CFSocketInvalidate(socket);
		CFRelease(socket);
	}
	[service removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[service stop];
	[service release];
	[super dealloc];
}

#pragma mark -
#pragma mark Server

// !!!: This function can be done in the presentation
void AcceptCallback (CFSocketRef s, CFSocketCallBackType callbackType, CFDataRef address, const void *data, void *info) {
	TWServer * self = (TWServer *) info;
	CFSocketNativeHandle handle = *((CFSocketNativeHandle*)data);
	[self acceptConnectionWithNativeHandle:handle];
}

// !!!: This method can be done in the presentation
- (BOOL) startServerWithError:(NSError **)error {
	
	// Create socket
	CFSocketContext context = {0, self, NULL, NULL, NULL};
	socket = CFSocketCreate(kCFAllocatorDefault,
							PF_INET,
							SOCK_STREAM,
							IPPROTO_TCP,
							kCFSocketAcceptCallBack,
							&AcceptCallback,
							&context);
	
	// Error check
	if (!socket) {
		if (error) {
			*error = [NSError errorWithDomain:TWServerErrorDomain code:TWServerErrorCreationFailed userInfo:
					  [NSDictionary dictionaryWithObjectsAndKeys:
					   NSLocalizedString(@"Unable to create the socket.", nil), NSLocalizedDescriptionKey,
					   nil]];
		}
		return NO;
	}
	
	// Create socket address
	struct sockaddr_in socketAddress;
	memset(&socketAddress, 0, sizeof(socketAddress));
	socketAddress.sin_len = sizeof(socketAddress);
	socketAddress.sin_family = AF_INET;
	socketAddress.sin_port = htons(0);
	socketAddress.sin_addr.s_addr = htonl(INADDR_ANY);
	
	NSData *socketAddressData = [NSData dataWithBytes:&socketAddress length:sizeof(socketAddress)];
	
	// Bind the socket
	if (CFSocketSetAddress(socket, (CFDataRef)socketAddressData) != kCFSocketSuccess) {
		// Error check
		if (error) {
			*error = [NSError errorWithDomain:TWServerErrorDomain code:TWServerErrorBindFailed userInfo:
					  [NSDictionary dictionaryWithObjectsAndKeys:
					   NSLocalizedString(@"Unable to bind the socket.", nil), NSLocalizedDescriptionKey,
					   nil]];
		}
		return NO;
	}
	
	// Get the port number
	socketAddressData = (NSData *)CFSocketCopyAddress(socket);
	memcpy(&socketAddress, [socketAddressData bytes], [socketAddressData length]);
	port = ntohs(socketAddress.sin_port);
	[socketAddressData release];
	
	// Schedule the socket in the run loop
	CFRunLoopRef currentRunLoop = CFRunLoopGetCurrent();
    CFRunLoopSourceRef runLoopSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
    CFRunLoopAddSource(currentRunLoop, runLoopSource, kCFRunLoopCommonModes);
    CFRelease(runLoopSource);
	
	return YES;
}

// !!!: This method can be done in the presentation
- (void) acceptConnectionWithNativeHandle:(CFSocketNativeHandle)handle {
	TWConnection * connection = [[TWConnection alloc] initWithNativeHandle:handle];
	[delegate server:self didMakeConnection:connection];
	[connection release];
}

#pragma mark -
#pragma mark Bonjour

// !!!: This method can be done in the presentation
- (void) publishService {
	self.service = [[[NSNetService alloc] initWithDomain:@"" type:TWNetServiceType name:@"" port:port] autorelease];
	[service scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[service setDelegate:self];
	[service publish];
}

#pragma mark -
#pragma mark Stop

- (void) stop {
	if (socket) {
		CFSocketInvalidate(socket);
		CFRelease(socket);
		socket = NULL;
	}
	[service stop];
	self.service = nil;
}

@end
