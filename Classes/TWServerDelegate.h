//
//  TWServerDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWServer, TWConnection;

@protocol TWServerDelegate

- (void) server:(TWServer *)server didMakeConnection:(TWConnection *)connection;

@end
