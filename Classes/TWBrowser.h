//
//  TWBonjourBrowser.h
//  TankWars
//
//  Created by Cory Kilger on 1/11/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWBrowserDelegate.h"


@interface TWBrowser : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, assign) id<TWBrowserDelegate> delegate;

- (id)initWithType:(NSString *)type domain:(NSString *)domain;
- (void) resolveService:(NSNetService *)aNetService;

@end
