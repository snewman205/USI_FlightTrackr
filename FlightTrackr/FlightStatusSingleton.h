//
//  FlightStatusSingleton.h
//  FlightTrackr
//
//  Created by Scott Newman on 10/20/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlightStatusSingleton : NSObject

@property (strong, nonatomic) NSString *destinationLocation;
@property (strong, nonatomic) NSString *destinationAirport;
@property (strong, nonatomic) NSString *originLocation;
@property (strong, nonatomic) NSString *originAirport;
@property (strong, nonatomic) NSString *faFlightID;
@property (strong, nonatomic) NSString *flightIdent;
@property (strong, nonatomic) NSString *carrierIdent;
@property (strong, nonatomic) NSString *originIdent;
@property (strong, nonatomic) NSString *destinationIdent;
@property (strong, nonatomic) NSString *flightNo;
@property (strong, nonatomic) NSString *bagClaim;
@property (nonatomic) BOOL didChangeFlight;
@property (nonatomic) double departs;

+ (FlightStatusSingleton *)sharedInstance;

@end
