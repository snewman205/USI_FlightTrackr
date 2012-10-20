//
//  FlightStatus.h
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckFlightStatus.h"
#import "LGViewHUD.h"

@interface FlightStatus : UITableViewController

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableArray *flightInfo;
@property (strong, nonatomic) CheckFlightStatus *previousView;
@property (strong, nonatomic) NSDate *roundedDate;
@property (strong, nonatomic) NSMutableArray *filteredFlights;
@property (strong, nonatomic) NSString *aircraftMfg;
@property (strong, nonatomic) NSString *aircraftType;
@property (nonatomic) BOOL dataReturned;

@end
