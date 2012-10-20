//
//  CheckFlightStatusSingleton.m
//  FlightTrackr
//
//  Created by Unbounded on 10/6/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "CheckFlightStatusSingleton.h"

@implementation CheckFlightStatusSingleton

static CheckFlightStatusSingleton *sharedSingletonClass = nil;

+ (CheckFlightStatusSingleton *)sharedInstance
{
    if(sharedSingletonClass == nil)
    {
        sharedSingletonClass = [[CheckFlightStatusSingleton alloc] init];
    }
    
    return sharedSingletonClass;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        
        self.destOrOriginSelected = [[NSString alloc] init];
        self.selectedOriginAirport = [[NSString alloc] init];
        self.selectedOriginIdent = [[NSString alloc] init];
        self.selectedDestinationAirport = [[NSString alloc] init];
        self.selectedDestinationIdent = [[NSString alloc] init];
        self.selectedAirlineName1 = [[NSString alloc] init];
        self.selectedAirlineIdent1 = [[NSString alloc] init];
        self.selectedAirlineName2 = [[NSString alloc] init];
        self.selectedAirlineIdent2 = [[NSString alloc] init];
        self.selectedFlightNo = [[NSString alloc] init];
        self.didSelectDate = NO;
        self.didSelectDate1 = NO;
        self.didSearchFlight = NO;
        self.selectedAirlineIndex1 = -1;
        self.selectedAirlineIndex2 = -1;
        self.selectedDateIndex = [NSDate date];
        self.selectedDateIndex1 = [NSDate date];
    }
    
    return self;
}

- (NSDate*)epochToDate:(double)epoch
{
    double secondsSinceEpoch = epoch - 3600;
    return [NSDate dateWithTimeIntervalSince1970:secondsSinceEpoch];
}


@end
