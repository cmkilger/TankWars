//
//  TWIOSConnectingViewController.h
//  TankWars
//
//  Created by Cory Kilger on 1/12/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	TWIOSConnectingTypeCreate,
	TWIOSConnectingTypeJoin,
} TWIOSConnectingType;

@interface TWIOSConnectingViewController : UITableViewController

- (id) initWithType:(TWIOSConnectingType)type;

@end
