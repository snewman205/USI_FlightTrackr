//
//  FlightStatus.h
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckFlightStatus.h"

@interface FlightStatus : UITableViewController

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableArray *flightInfo;
@property (strong, nonatomic) CheckFlightStatus *previousView;

@end
