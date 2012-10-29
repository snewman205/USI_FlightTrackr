//
//  FlightStatusResults.h
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LGViewHUD.h"
#import "CheckFlightStatusSingleton.h"
#import "FlightStatusSingleton.h"

@interface FlightStatusResults : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *returnedFlights;
@property (strong, nonatomic) NSMutableArray *filteredFlights;
@property (strong, nonatomic) CheckFlightStatusSingleton *singletonObj;
@property (strong, nonatomic) NSArray *airlineLogos;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
- (IBAction)btnEdit:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnDoEdit;

- (UIImage*)getAirlineLogo: (NSString*)airline;

@end
