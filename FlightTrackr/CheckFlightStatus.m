//
//  CheckFlightStatus.m
//  FlightTrackr
//
//  Created by Unbounded on 9/29/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "CheckFlightStatus.h"
#import "AirportSelector.h"

@interface CheckFlightStatus ()

@end

@implementation CheckFlightStatus

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {}
    
    return self;
}

#pragma mark - TableView delegate

// Setting up the table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionHeaders count];
}

- (void)doneCancelNumberPadToolbarDelegate:(DoneCancelNumberPadToolbar *)controller didClickCancel:(UITextField *)textField
{
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Assign section headers
    return [self.sectionHeaders objectAtIndex:(NSUInteger)section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSInteger numRows;
    
    switch(section)
    {
        case 0:
            numRows = 3;
        break;
        case 1:
            numRows = 4;
        break;
        case 2:
            numRows = 1;
        break;
    }
    
    return numRows;
}

// building the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    CheckFlightStatusCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CheckFlightStatusCell"];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
                
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            if(self.singletonObj.selectedAirlineIndex1 == -1)
            {
                        
                cell.textLabel.text = @"Select an airline...";
                cell.detailTextLabel.text = @"";
                        
            }
            else
            {
                cell.textLabel.text = @"Airline:";
                cell.detailTextLabel.text = self.singletonObj.selectedAirlineName1;
            }
                
        }
    
        else if(indexPath.row == 1)
        {
                
            cell1.inpMenuItem.placeholder = @"5254";
            cell1.inpMenuItem.keyboardType = UIKeyboardTypeNumberPad;
            DoneCancelNumberPadToolbar *toolbar = [[DoneCancelNumberPadToolbar alloc] initWithTextField:cell1.inpMenuItem];
            [toolbar setDelegate:self];
            [cell1.inpMenuItem setInputAccessoryView:toolbar];
            [cell1.inpMenuItem addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
            cell1.inpMenuItem.hidden = NO;
            cell1.inpMenuItem.enabled = YES;
            cell1.lblMenuItemLabel.text = @"Flight #:";
            [cell1 setAccessoryType:UITableViewCellAccessoryNone];
                    
            return cell1;
                    
        }
                    
        else if(indexPath.row == 2)
        {
                
            [dateFormat1 setDateFormat:@"MMM dd yyyy - h:mm a"];
                    
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    
            if(!self.singletonObj.didSelectDate1)
            {
                cell.textLabel.text = @"Select departure date...";
                cell.detailTextLabel.text = @"";
            }
            else
            {
                cell.textLabel.text = @"Departure:";
                cell.detailTextLabel.text = [dateFormat1 stringFromDate:self.singletonObj.selectedDateIndex1];
            }
                    
        }
                 
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            if(self.singletonObj.selectedAirlineIndex2 == -1)
            {
                cell.textLabel.text = @"Select an airline...";
                cell.detailTextLabel.text = @"";
            }
            else
            {
                cell.textLabel.text = @"Airline:";
                cell.detailTextLabel.text = self.singletonObj.selectedAirlineName2;
            }
                    
        }
        
        else if(indexPath.row == 1)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    
            if(self.singletonObj.selectedOriginAirport.length > 0)
            {
                cell.textLabel.text = @"Origin:";
                cell.detailTextLabel.text = self.singletonObj.selectedOriginAirport;
            }
            else
            {
                cell.textLabel.text = @"Select origin airport...";
                cell.detailTextLabel.text = @"";
            }
                    
        }
        
        else if(indexPath.row == 2)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            if(self.singletonObj.selectedDestinationAirport.length > 0)
            {
                cell.textLabel.text = @"Destination:";
                cell.detailTextLabel.text = self.singletonObj.selectedDestinationAirport;
            }
            else
            {
                cell.textLabel.text = @"Select destination airport...";
                cell.detailTextLabel.text = @"";
            }
        }
        
        else if(indexPath.row == 3)
        {
            [dateFormat1 setDateFormat:@"MMM dd yyyy - h:mm a"];
                
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;

            if(!self.singletonObj.didSelectDate)
            {
                cell.textLabel.text = @"Select departure date...";
                cell.detailTextLabel.text = @"";
            }
            else
            {
                cell.textLabel.text = @"Departure:";
                cell.detailTextLabel.text = [dateFormat1 stringFromDate:self.singletonObj.selectedDateIndex];
            }
        }
        
    }
    
    else if(indexPath.section == 2)
    {
            if(indexPath.row == 0)
            {
                cell.textLabel.text = @"Choose from my favorites...";
                cell.detailTextLabel.text = @"";
            }
    }

    return cell;

}

// cell click
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actSheet = [UIActionSheet alloc];
    self.selectedCell = (CheckFlightStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedPath = indexPath;
    MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Flight Status" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    switch(indexPath.section)
    {
        case 0:
            
            switch(indexPath.row)
            {
                case 0:
                    
                    self.actSheet = [self.actSheet initWithTitle:@"Choose Airline" delegate:self cancelButtonTitle:@"Cancel"            destructiveButtonTitle:nil otherButtonTitles:@"Choose", nil];
                    [self.actSheet showInView:self.view];
                    [self.actSheet setFrame:CGRectMake(0, 80, 320, 383)];
                    [self.actSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                break;
                    
                case 2:
                    
                    self.actSheet = [self.actSheet initWithTitle:@"Choose Departure Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Choose", nil];
                    [self.actSheet showInView:self.view];
                    [self.actSheet setFrame:CGRectMake(0, 80, 320, 383)];
                    [self.actSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                break;
                    
            }
        
        break;
            
        case 1:
        
            switch(indexPath.row)
            {
                
                case 0:
                    
                    self.actSheet = [self.actSheet initWithTitle:@"Choose Airline" delegate:self cancelButtonTitle:@"Cancel"            destructiveButtonTitle:nil otherButtonTitles:@"Choose", nil];
                    [self.actSheet showInView:self.view];
                    [self.actSheet setFrame:CGRectMake(0, 80, 320, 383)];
                    [self.actSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                break;
                    
                case 1:
            
                    [self performSegueWithIdentifier:@"segueAirportSelector" sender:self];
                    
                break;
                    
                case 2:
                    
                    [self performSegueWithIdentifier:@"segueAirportSelector" sender:self];
                    
                break;
                    
                case 3:
                    
                    self.actSheet = [self.actSheet initWithTitle:@"Choose Departure Date" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Choose", nil];
                    [self.actSheet showInView:self.view];
                    [self.actSheet setFrame:CGRectMake(0, 80, 320, 383)];
                    [self.actSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                    
                break;
                    
            }
            
        break;
     
        case 2:
            
            switch(indexPath.row)
            {
                case 0:
                    
                    singletonObj.selectedFavorites = @"flights";
                    [self performSegueWithIdentifier:@"segueFaves" sender:self];
                    
                break;
                    
            }
            
        break;
            
    }
}

#pragma mark - TextField delegate

// text field handler
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ActionSheet / PickerView delegate

// actionsheet onLoad
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    // are we loading a date picker or picker view?
    if((self.selectedPath.section == 1 && self.selectedPath.row == 3) || (self.selectedPath.section == 0 && self.selectedPath.row == 2))
    {
        // date picker it is!
        self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 140)];
        self.datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePickerView.date = [NSDate date];

        if(self.selectedPath.section == 1)
        {
            [self.datePickerView setDate:self.singletonObj.selectedDateIndex];
        }
        else
        {
            [self.datePickerView setDate:self.singletonObj.selectedDateIndex1];
        }
        
        [self.actSheet addSubview:self.datePickerView];
        NSArray *subviews = [self.actSheet subviews];
        [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 270, 280, 46)];
    }
    else
    {
        // regular picker!
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 140)];
    
        // Read & sort airline names
        NSString *airlinesDataPath = [[NSBundle mainBundle] pathForResource:@"Airlines" ofType:@"plist"];
        NSMutableArray *airlines = [[NSMutableArray alloc] init];
    
        self.airlineDict = [[NSDictionary alloc] initWithContentsOfFile:airlinesDataPath];
        for (NSString *key in [self.airlineDict allKeys])
        {
            NSDictionary *airline = [self.airlineDict objectForKey:key];
            [airlines addObject:[airline valueForKey:@"Name"]];
        }
        [airlines sortUsingSelector:@selector(caseInsensitiveCompare:)];
        self.airlineNames = airlines;
    
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        self.pickerView.showsSelectionIndicator = YES;
        NSInteger indexToReturn = (self.selectedPath.section == 0) ? self.singletonObj.selectedAirlineIndex1 : self.singletonObj.selectedAirlineIndex2;
        [self.pickerView selectRow:indexToReturn inComponent:0 animated:NO];
    
        //Add picker to action sheet
        [self.actSheet addSubview:self.pickerView];
        NSArray *subviews = [self.actSheet subviews];
        [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 216, 280, 46)];
        [[subviews objectAtIndex:2] setFrame:CGRectMake(20, 277, 280, 46)];
        
    }

}

// BEGIN UIPickerView config
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.airlineNames count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.airlineNames objectAtIndex:row];
}
// END UIPickerView config

// actionsheet button click handler
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
            
            if(self.selectedPath.section == 0)
            {
                if(self.selectedPath.row == 2)
                {
                    self.singletonObj.didSelectDate1 = YES;
                    self.singletonObj.selectedDateIndex1 = [self.datePickerView date];
                }
                else
                {
                    self.singletonObj.selectedAirlineIndex1 = [self.pickerView selectedRowInComponent:0];
                    self.singletonObj.selectedAirlineName1 = [self.airlineNames objectAtIndex:[self.pickerView selectedRowInComponent:0]];
                    NSDictionary *airlineData = [self.airlineDict objectForKey:self.singletonObj.selectedAirlineName1];
                    self.singletonObj.selectedAirlineIdent1 = [airlineData objectForKey:@"Identifier"];
                }
            }
            else
            {
                if(self.selectedPath.row == 0)
                {
                    self.singletonObj.selectedAirlineIndex2 = [self.pickerView selectedRowInComponent:0];
                    self.singletonObj.selectedAirlineName2 = [self.airlineNames objectAtIndex:[self.pickerView selectedRowInComponent:0]];
                    NSDictionary *airlineData = [self.airlineDict objectForKey:self.singletonObj.selectedAirlineName2];
                    self.singletonObj.selectedAirlineIdent2 = [airlineData objectForKey:@"Identifier"];
                }
                else if(self.selectedPath.row == 3)
                {
                        self.singletonObj.didSelectDate = YES;
                        self.singletonObj.selectedDateIndex = [self.datePickerView date];
                }
            }

            [self.actSheet dismissWithClickedButtonIndex:0 animated:YES];
            
            if(self.selectedPath.row == 0)
            {
                
                self.selectedCell.textLabel.text = @"Airline:";
                self.selectedCell.detailTextLabel.text = [self.airlineNames objectAtIndex:[self.pickerView selectedRowInComponent:0]];
                
            }
            else if((self.selectedPath.section == 0 && self.selectedPath.row == 2) || (self.selectedPath.section == 1 && self.selectedPath.row == 3))
            {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM dd yyyy - h:mm a"];
                
                self.selectedCell.textLabel.text = @"Departure:";
                
                if(self.selectedPath.row == 2)
                {
                    self.selectedCell.detailTextLabel.text = [dateFormat stringFromDate:self.singletonObj.selectedDateIndex1];
                }
                else
                {
                    self.selectedCell.detailTextLabel.text = [dateFormat stringFromDate:self.singletonObj.selectedDateIndex];
                }
                
            }
            
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
        
        break;
            
        case 1:
            
            [self.actSheet dismissWithClickedButtonIndex:1 animated:YES];
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
            
        break;
            
    }
}

#pragma mark - View handlers

// onLoad
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.singletonObj = [CheckFlightStatusSingleton sharedInstance];
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Search by Flight Number", @"Search by Origin or Destination", @"Favorites", nil];
    
}

// onAppear
- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doCheckStatus:(id)sender
{
    // make sure they have specified either a flight number or search parameters
    
    FlightStatusSingleton *singletonObj = [FlightStatusSingleton sharedInstance];
    CheckFlightStatusCell *cell2 = (CheckFlightStatusCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please specify a flight number or search parameters" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    BOOL shouldSearchFlightNumber = NO;
    
    if(self.singletonObj.selectedAirlineIndex1 == -1 || [cell2.inpMenuItem.text isEqualToString:@""] || !self.singletonObj.didSelectDate1)
    {
        if(self.singletonObj.selectedAirlineIndex2 == -1 && [self.singletonObj.selectedOriginAirport isEqualToString:@""] && [self.singletonObj.selectedDestinationAirport isEqualToString:@""] && !self.singletonObj.didSelectDate)
        {
            [error show];
            return;
        }
        else
        {
            shouldSearchFlightNumber = YES;
        }
    }
    
    if(shouldSearchFlightNumber)
    {
        [self performSegueWithIdentifier:@"segueSearchFlightNum" sender:self];
    }
    else
    {
        singletonObj.didChangeFlight = YES;
        self.singletonObj.selectedFlightNo = cell2.inpMenuItem.text;
        [self performSegueWithIdentifier:@"segueFlightStatus" sender:self];
    }
    
}

- (void)doneCancelNumberPadToolbarDelegate:(DoneCancelNumberPadToolbar *)controller didClickDone:(UITextField *)textField
{
    [textField resignFirstResponder];
}

// pass data to next view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    self.singletonObj.destOrOriginSelected = (selectedRowIndex.row == 1) ? @"Origin" : @"Destination";
}

- (void)viewDidUnload {
    [self setBtnCheckStatus:nil];
    [self setLblMenuItem:nil];
    [super viewDidUnload];
}


@end
