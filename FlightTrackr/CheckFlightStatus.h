//
//  CheckFlightStatus.h
//  FlightTrackr
//
//  Created by Unbounded on 9/29/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckFlightStatusCell.h"
#import "CheckFlightStatusSingleton.h"
#import "FlightStatusSingleton.h"
#import "DoneCancelNumberPadToolbar.h"
#import "MainMenuSingleton.h"

@interface CheckFlightStatus : UITableViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, DoneCancelNumberPadToolbarDelegate>

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSArray *sectionContent;
@property (strong, nonatomic) NSArray *airlineNames;
@property (strong, nonatomic) NSDictionary *airlineDict;
@property (strong, nonatomic) UIActionSheet *actSheet;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) NSIndexPath *selectedPath;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckStatus;
@property (strong, nonatomic) CheckFlightStatusCell *selectedCell;
@property (strong, nonatomic) CheckFlightStatusSingleton *singletonObj;
@property (strong, nonatomic) IBOutlet UILabel *lblMenuItem;
@property (nonatomic) BOOL *airline1Adjusted;
@property (nonatomic) BOOL *airline2Adjusted;

- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (IBAction)doCheckStatus:(id)sender;

@end
