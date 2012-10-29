//
//  AirportSelector.h
//  FlightTrackr
//
//  Created by Unbounded on 9/29/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirportSelectorCell.h"
#import "MainMenuSingleton.h"

@interface AirportSelector : UITableViewController <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *sectionHeaders;
@property (strong, nonatomic) NSArray *stateNames;
@property (strong, nonatomic) NSArray *cityNames;
@property (strong, nonatomic) NSString *airportDataPath;
@property (strong, nonatomic) NSString *cityOrState;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSDictionary *airportDict;
@property (strong, nonatomic) UIActionSheet *actSheet;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) AirportSelectorCell *selectedCell;
@property (strong, nonatomic) IBOutlet UITextField *inpMenuItem;
@property (strong, nonatomic) IBOutlet UILabel *lblMenuItemLabel;
@property (nonatomic) BOOL didSelectState;
@property (nonatomic) BOOL didStateChange;
@property (nonatomic) NSInteger selectedStateIndex;
@property (nonatomic) NSInteger selectedCityIndex;

- (IBAction)doAirportSearch:(id)sender;

@end
