//
//  AirportSingleton.m
//  FlightTrackr
//
//  Created by Unbounded on 10/23/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportSingleton.h"

@implementation AirportSingleton

static AirportSingleton *sharedSingletonClass = nil;

+ (AirportSingleton *)sharedInstance
{
    if(sharedSingletonClass == nil)
    {
        sharedSingletonClass = [[AirportSingleton alloc] init];
    }
    
    return sharedSingletonClass;
}

- (id)init
{    
    self = [super init];
    
    if(self)
    {
        self.airportIdent = [[NSString alloc] init];
        self.airportName = [[NSString alloc] init];
        self.airportCity = [[NSString alloc] init];
        self.airportState = [[NSString alloc] init];
        self.airportGoogleName = [[NSString alloc] init];
        self.airportGoogleAddress = [[NSString alloc] init];
        self.localPlacesResults = [[NSArray alloc] init];
        self.googleRef = [[NSString alloc] init];
        self.didChangeAirport = YES;
    }
    
    return self;
}

- (void)saveValues
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *testStr = self.googleRef;
    
    [defaults setObject:testStr forKey:@"googleRefKey"];
    
    [defaults synchronize];
}

- (NSString*)readValues
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *readValString = [defaults objectForKey:@"googleRefKey"];
    
    return readValString;
}

@end
