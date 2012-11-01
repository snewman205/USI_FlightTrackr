//
//  SettingsCell.h
//  FlightTrackr
//
//  Created by Unbounded on 10/26/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsCell : UITableViewCell <UIAlertViewDelegate>

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (IBAction)doReset:(id)sender;

@end
