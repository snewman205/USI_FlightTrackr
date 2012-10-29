//
//  CheckFlightStatusSingleton.h
//  FlightTrackr
//
//  Created by Unbounded on 10/6/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckFlightStatusSingleton : NSObject

@property (strong, nonatomic) NSString *destOrOriginSelected;
@property (strong, nonatomic) NSDate *selectedDateIndex;
@property (strong, nonatomic) NSDate *selectedDateIndex1;
@property (strong, nonatomic) NSString *selectedOriginAirport;
@property (strong, nonatomic) NSString *selectedOriginIdent;
@property (strong, nonatomic) NSString *selectedDestinationAirport;
@property (strong, nonatomic) NSString *selectedDestinationIdent;
@property (strong, nonatomic) NSString *selectedAirlineName1;
@property (strong, nonatomic) NSString *selectedAirlineIdent1;
@property (strong, nonatomic) NSString *selectedAirlineName2;
@property (strong, nonatomic) NSString *selectedAirlineIdent2;
@property (strong, nonatomic) NSString *selectedFlightNo;
@property (nonatomic) NSInteger selectedAirlineIndex1;
@property (nonatomic) NSInteger selectedAirlineIndex2;
@property (nonatomic) BOOL didSelectDate;
@property (nonatomic) BOOL didSelectDate1;
@property (nonatomic) BOOL didSearchFlight;

+ (CheckFlightStatusSingleton *)sharedInstance;
- (NSDate*)epochToDate:(double)epoch;

@end
