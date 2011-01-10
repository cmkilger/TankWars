//
//  TWConnectionDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 12/10/10.
//  Copyright 2010 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWConnection;

@protocol TWConnectionDelegate <NSObject>

- (void) connection:(TWConnection *)connection didReceiveData:(NSData *)data;
- (void) connectionDidEnd:(TWConnection *)connection;

@end
