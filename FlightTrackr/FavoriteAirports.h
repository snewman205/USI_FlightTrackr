//
//  FavoriteAirports.h
//  FlightTrackr
//
//  Created by Unbounded on 10/11/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CheckFlightStatusSingleton.h"
#import "MainMenuSingleton.h"
#import "AirportSingleton.h"
#import "AirportSelectorResultsObj.h"
#import "CheckFlightStatus.h"
#import "LGViewHUD.h"
#import "FlightSelectorResultsObj.h"

@interface FavoriteAirports : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableArray *airports;
@property (strong, nonatomic) NSMutableArray *flights;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) IBOutlet UISegmentedControl *btnChangeFavorites;
@property (strong, nonatomic) NSArray *airlineLogos;
@property (nonatomic) BOOL editing;
@property (nonatomic) BOOL loadingAirports;

- (IBAction)doChangeFavorites:(id)sender;


- (void)loadAirports;
- (void)loadFlights;

@end
