//
//  ForecastObject.h
//  FlightTrackr
//
//  Created by Unbounded on 10/22/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForecastObject : NSObject

@property (strong, nonatomic) NSString *iconURL;
@property (strong, nonatomic) NSString *currentConditions;
@property (strong, nonatomic) NSString *windStr;
@property (nonatomic) double currentTemperature;
@property (nonatomic) double feelsLikeTemperature;

@end
