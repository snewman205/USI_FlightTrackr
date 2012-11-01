//
//  ForecastObject.m
//  FlightTrackr
//
//  Created by Unbounded on 10/22/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "ForecastObject.h"

@implementation ForecastObject

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.iconURL = [[NSString alloc] init];
        self.currentConditions = [[NSString alloc] init];
        self.windStr = [[NSString alloc] init];
        self.currentTemperature = 0;
        self.feelsLikeTemperature = 0;
        
    }
    
    return self;
}


@end
