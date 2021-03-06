//
//  TWIOSNewGameViewController.m
//  TankWars
//
//  Created by Cory Kilger on 1/12/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWIOSNewGameViewController.h"
#import "TWIOSConnectingViewController.h"


@implementation TWIOSNewGameViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -


- (IBAction) createGame {
	TWIOSConnectingViewController * connecting = [[TWIOSConnectingViewController alloc] initWithType:TWIOSConnectingTypeCreate];
	[self.navigationController pushViewController:connecting animated:YES];
	[connecting release];
}

- (IBAction) joinGame {
	TWIOSConnectingViewController * connecting = [[TWIOSConnectingViewController alloc] initWithType:TWIOSConnectingTypeJoin];
	[self.navigationController pushViewController:connecting animated:YES];
	[connecting release];
}

@end
