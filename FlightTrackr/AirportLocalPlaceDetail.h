//
//  AirportLocalPlaceDetail.h
//  FlightTrackr
//
//  Created by Unbounded on 10/24/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "LGViewHUD.h"
#import "AirportSingleton.h"
#import "AppDelegate.h"

@interface AirportLocalPlaceDetail : UITableViewController

@property (nonatomic) BOOL dataReturned;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *addressComponents;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) IBOutlet UILabel *lblTTC;
@property (strong, nonatomic) NSString *streetNo;
@property (strong, nonatomic) NSString *street;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zip;

@end
