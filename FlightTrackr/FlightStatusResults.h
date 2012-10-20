//
//  FlightStatusResults.h
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckFlightStatus.h"

@interface FlightStatusResults : UITableViewController

@property (strong, nonatomic) NSArray *returnedFlights;
@property (strong, nonatomic) NSMutableArray *filteredFlights;
@property (strong, nonatomic) CheckFlightStatus *previousView;
@property (strong, nonatomic) NSArray *airlineLogos;

- (UIImage*)getAirlineLogo: (NSString*)airline;

@end
