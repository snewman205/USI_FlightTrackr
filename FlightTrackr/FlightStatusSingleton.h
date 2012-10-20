//
//  FlightStatusSingleton.h
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightStatusSingleton : NSObject

@property (strong, nonatomic) NSString *destinationAirport;
@property (strong, nonatomic) NSString *originAirport;

+ (FlightStatusSingleton *)sharedInstance;

@end
