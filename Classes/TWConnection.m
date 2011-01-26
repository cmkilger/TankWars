//
//  TWConnection.m
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import "TWConnection.h"

@interface TWConnection ()

@property (nonatomic, retain) NSInputStream * input;
@property (nonatomic, retain) NSOutputStream * output;

@property (nonatomic, retain) NSMutableData * unsentData;

@end


@implementation TWConnection

// !!!: This can be done in the presentation
- (id) initWithNativeHandle:(CFSocketNativeHandle)handle {
	if (!(self = [super init]))
		return nil;
	
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, handle, (CFReadStreamRef *)&input, (CFWriteStreamRef *)&output);
	
	if (!input || !output) {
		[self release];
		return nil;
	}
	
	input.delegate = self;
	output.delegate = self;
	[input scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[output scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[input open];
	[output open];
	
	self.unsentData = [NSMutableData data];
	
	return self;
}

// !!!: This can be done in the presentation
- (id) initWithService:(NSNetService *)service {
	if (!(self = [super init]))
		return nil;
	
	if (![service getInputStream:&input outputStream:&output]) {
		[self release];
		return nil;
	}
	
	input.delegate = self;
	output.delegate = self;
	[input scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[output scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[input open];
	[output open];
		
	self.unsentData = [NSMutableData data];
	
	NSLog(@"input: %@", input);
	NSLog(@"output: %@", output);
	
	return self;
}

- (void) dealloc {
	[unsentData release];
	input.delegate = nil;
	output.delegate = nil;
	[input removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[output removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
	[input close];
	[output close];
	[input release];
	[output release];
	[super dealloc];
}

#pragma mark -

// !!!: This can be done in the presentation
- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	// Read from input
	if (aStream == input && eventCode == NSStreamEventHasBytesAvailable) {
		NSMutableData * data = [NSMutableData data];
		NSUInteger bufferSize = 1024;
		uint8_t buffer[bufferSize];
		while ([input hasBytesAvailable]) {
			NSInteger length = [input read:buffer maxLength:bufferSize];
			[data appendBytes:buffer length:length];
		}
		[delegate connection:self didReceiveData:data];
	}
	
	// Write to output
	else if (aStream == output && eventCode == NSStreamEventHasSpaceAvailable) {
		[self sendData:nil];
	}
	
	// Close streams
	else if (eventCode == NSStreamEventEndEncountered) {
		input.delegate = nil;
		output.delegate = nil;
		[input removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		[output removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		[input close];
		[output close];
		[delegate connectionDidEnd:self];
	}
}

// !!!: This can be done in the presentation
- (void) sendData:(NSData *)data {
	[unsentData appendData:data];
	uint8_t * bytes = (uint8_t *) [unsentData bytes];
	NSUInteger length = [unsentData length];
	NSUInteger index = 0;
	while ([output hasSpaceAvailable] && index < length)
		index += [output write:&(bytes[index]) maxLength:length-index];
	[unsentData replaceBytesInRange:NSMakeRange(0, index) withBytes:NULL length:0];
}

@end
