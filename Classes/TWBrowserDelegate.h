//
//  TWBonjourBrowserDelegate.h
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWBrowser;

@protocol TWBrowserDelegate

- (void) browser:(TWBrowser *)browser didFindService:(NSNetService *)service;
- (void) browser:(TWBrowser *)browser didRemoveService:(NSNetService *)service;
- (void) browser:(TWBrowser *)browser didResolveService:(NSNetService *)service;

@end
