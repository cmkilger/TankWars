//
//  TWBonjourBrowserDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWBrowser;
@class TWConnection;

@protocol TWBrowserDelegate

- (void) browser:(TWBrowser *)browser didFindService:(NSNetService *)service;
- (void) browser:(TWBrowser *)browser didRemoveService:(NSNetService *)service;
- (void) browser:(TWBrowser *)browser didMakeConnection:(TWConnection *)connection;
- (void) browser:(TWBrowser *)browser didNotResolveService:(NSNetService *)service errorDict:(NSDictionary *)errorDict;

@end
