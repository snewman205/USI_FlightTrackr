//
//  MainMenu.m
//  FlightTrackr
//
//  Created by Unbounded on 9/28/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "MainMenu.h"
#import "MainMenuCell.h"
#import "CheckFlightStatus.h"

@interface MainMenu ()

@end

@implementation MainMenu

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.menuItems = [[NSArray alloc] initWithObjects:@"Check Flight Status", @"Find An Airport", @"Settings", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainMenuCell";
    MainMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    cell.lblMenuItem.text = [self.menuItems objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
    
    switch (indexPath.row)
    {
        case 0:
            singletonObj.selectedItem = 0;
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:nil action:nil];
            [self performSegueWithIdentifier:@"segueCheckFlightStatus" sender:self];
        break;
            
        case 1:
            singletonObj.selectedItem = 1;
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:nil action:nil];
            [self performSegueWithIdentifier:@"segueFindAirport" sender:self];
        break;
        
        case 2:
            self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:nil action:nil];
            [self performSegueWithIdentifier:@"segueSettings" sender:self];
        break;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
