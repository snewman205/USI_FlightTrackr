//
//  CurrentConditions.h
//  FlightTrackr
//
//  Created by Unbounded on 10/22/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGViewHUD.h"
#import "FlightStatusSingleton.h"
#import "ForecastObject.h"
#import "AppDelegate.h"

@interface CurrentConditions : UITableViewController

@property (strong, nonatomic) NSString *userUnits;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) ForecastObject *originForecast;
@property (strong, nonatomic) ForecastObject *destinationForecast;
@property (strong, nonatomic) FlightStatusSingleton *singletonObj;
@property (nonatomic) BOOL dataReturned;
@property (nonatomic) BOOL displayWindConditions;

@end
