//
//  TWConnection.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWConnectionDelegate.h"

@interface TWConnection : NSObject <NSStreamDelegate>

@property (nonatomic, assign) id<TWConnectionDelegate> delegate;

- (id) initWithNativeHandle:(CFSocketNativeHandle)handle;
- (void) sendData:(NSData *)data;

@end
