//
//  TWIOSConnectingViewController.m
//  TankWars
//
//  Created by Cory Kilger on 1/12/11.
//  Copyright 2011 Cory Kilger. All rights reserved.
//

#import "TWIOSConnectingViewController.h"
#import "TWIOSAppDelegate.h"
#import "TWBrowser.h"
#import "TWGame.h"

@interface TWIOSConnectingViewController ()

@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) TWIOSConnectingType type;

@end


@implementation TWIOSConnectingViewController

- (id) initWithType:(TWIOSConnectingType)newType {
	if (![super initWithStyle:UITableViewStylePlain])
		return nil;
	
	self.type = newType;
		
	TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.players = [NSMutableArray array];
	
	if (type == TWIOSConnectingTypeCreate) {
		appDelegate.game = [[[TWGame alloc] init] autorelease];
		appDelegate.game.delegate = appDelegate;
	}
	else if (type == TWIOSConnectingTypeJoin) {
		appDelegate.browser = [[[TWBrowser alloc] initWithType:@"_tankwars._tcp." domain:@""] autorelease];
		appDelegate.browser.delegate = appDelegate;
	}
	
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.connectingTable = self.tableView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    return [appDelegate.players count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"Cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	id object = [appDelegate.players objectAtIndex:indexPath.row];
	cell.textLabel.text = [object name];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (type == TWIOSConnectingTypeJoin) {
		TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
		[appDelegate.browser resolveService:[appDelegate.players objectAtIndex:indexPath.row]];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.connectingTable = nil;
}

- (void)dealloc {
	TWIOSAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
	appDelegate.connectingTable = nil;
	if (!started)
		appDelegate.game = nil;
    [super dealloc];
}

@end

