//
//  AirportLocalPlacesList.h
//  FlightTrackr
//
//  Created by Unbounded on 10/24/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalPlacesObject.h"
#import "AirportSingleton.h"
#import "AppDelegate.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

@end;

@interface AirportLocalPlacesList : UIViewController

@property (strong, nonatomic) NSMutableArray *places;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSMutableArray *placesTemp;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnDismiss:(id)sender;


- (void)loadTableData;

@end
