//
//  AirportSelectorResults.h
//  FlightTrackr
//
//  Created by Unbounded on 9/30/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CheckFlightStatus.h"
#import "LGViewHUD.h"
#import "MainMenuSingleton.h"
#import "AirportSingleton.h"

@interface AirportSelectorResults : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *airports;
@property (strong, nonatomic) NSString *inpIdent;
@property (strong, nonatomic) NSString *inpState;
@property (strong, nonatomic) NSString *inpCity;
@property (strong, nonatomic) NSArray *airportItems;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSArray *airportResults;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (IBAction)doEdit:(id)sender;
- (void)loadTableData;

@end
