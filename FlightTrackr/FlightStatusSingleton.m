//
//  FlightStatusSingleton.m
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FlightStatusSingleton.h"

@implementation FlightStatusSingleton

static FlightStatusSingleton *sharedSingletonClass = nil;

+ (FlightStatusSingleton *)sharedInstance
{
    if(sharedSingletonClass == nil)
    {
        sharedSingletonClass = [[FlightStatusSingleton alloc] init];
    }
    
    return sharedSingletonClass;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.originLocation = [[NSString alloc] init];
        self.originAirport = [[NSString alloc] init];
        self.destinationLocation = [[NSString alloc] init];
        self.destinationAirport = [[NSString alloc] init];
        self.faFlightID = [[NSString alloc] init];
        self.flightIdent = [[NSString alloc] init];
        self.carrierIdent = [[NSString alloc] init];
        self.flightNo = [[NSString alloc] init];
        self.originIdent = [[NSString alloc] init];
        self.destinationIdent = [[NSString alloc] init];
        self.bagClaim = [[NSString alloc] init];
        self.didChangeFlight = NO;
    }
    
    return self;
}


@end
