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
#import "FlightStatusSingleton.h"
#import "AppDelegate.h"

@interface FlightStatus : UITableViewController <UIActionSheetDelegate>

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableArray *flightInfo;
@property (strong, nonatomic) CheckFlightStatusSingleton *singletonObj1;
@property (strong, nonatomic) FlightStatusSingleton *singletonObj;
@property (strong, nonatomic) NSDate *roundedDate;
@property (strong, nonatomic) NSMutableArray *filteredFlights;
@property (strong, nonatomic) NSString *aircraftMfg;
@property (strong, nonatomic) NSString *aircraftType;
@property (strong, nonatomic) NSString *origTerm;
@property (strong, nonatomic) NSString *origGate;
@property (strong, nonatomic) NSString *destTerm;
@property (strong, nonatomic) NSString *destGate;
@property (nonatomic) BOOL dataReturned;
@property (strong,nonatomic) UIActionSheet *actSheet;
@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

@end
