//
//  TWServer.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <arpa/inet.h>
#import "TWServerDelegate.h"

extern NSString * const TWServerErrorDomain;

typedef enum {
	TWServerErrorCreationFailed,
	TWServerErrorBindFailed,
	TWServerErrorPublishFailed,
} TWServerErrorCode;

@interface TWServer : NSObject <NSNetServiceDelegate>

@property (nonatomic, assign) id<TWServerDelegate> delegate;
@property (nonatomic, assign) UInt16 port;

- (id) initWithError:(NSError **)error;
- (void) stop;

@end
