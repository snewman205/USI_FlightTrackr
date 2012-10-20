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
        
    }
    
    return self;
}


@end
