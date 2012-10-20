//
//  FavoriteAirports.h
//  FlightTrackr
//
//  Created by Unbounded on 10/11/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CheckFlightStatus.h"

@interface FavoriteAirports : UITableViewController <UIAlertViewDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSMutableArray *airports;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sectionHeaders;

- (void)loadTableData;

@end
