//
//  MainMenu.h
//  FlightTrackr
//
//  Created by Unbounded on 9/28/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenuSingleton.h"

@interface MainMenu : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *menuItems;

@end
