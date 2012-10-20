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

// onLoad
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.singletonObj = [CheckFlightStatusSingleton sharedInstance];
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Search by Flight Number", @"Search by Origin or Destination", nil];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionHeaders count];
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
    }
    
    return numRows;
}

// building the cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckFlightStatusCell";
    CheckFlightStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDateFormatter *dateFormat1 = [[NSDateFormatter alloc] init];
    
    switch(indexPath.section)
    {
        case 0:
            
            switch(indexPath.row)
            {
                case 0:
                
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

                    if(self.singletonObj.selectedAirlineIndex1 == -1)
                    {
                        
                        cell.lblMenuItemLabel.text = @"Select an airline...";
                        
                    }
                    else
                    {
                        cell.lblMenuItemLabel.text = @"Airline:";
                        [cell.lblMenuItem setFrame:CGRectMake(75, cell.lblMenuItem.frame.origin.y, cell.lblMenuItem.frame.size.width, cell.lblMenuItem.frame.size.height)];
                        cell.lblMenuItem.text = self.singletonObj.selectedAirlineName1;
                        cell.lblMenuItem.hidden = NO;
                    }
                    
                break;
                    
                case 1:
                    
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.inpMenuItem.placeholder = @"5254";
                    cell.inpMenuItem.keyboardType = UIKeyboardTypeNumberPad;
                    [cell.inpMenuItem addTarget:self action:@selector(textFieldShouldReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];
                    cell.inpMenuItem.hidden = NO;
                    cell.inpMenuItem.enabled = YES;
                    cell.lblMenuItemLabel.text = @"Flight #:";
                    
                break;
                    
                case 2:
                    
                    [dateFormat1 setDateFormat:@"MMM dd yyyy - h:mm a"];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    
                    if(!self.singletonObj.didSelectDate1)
                    {
                        cell.lblMenuItemLabel.text = @"Select departure date...";
                    }
                    else
                    {
                        cell.lblMenuItemLabel.text = @"Departure:";
                        cell.lblMenuItem.hidden = NO;
                        cell.lblMenuItem.text = [dateFormat1 stringFromDate:self.singletonObj.selectedDateIndex1];
                    }
                    
                break;
                 
            }
            
        break;
            
        case 1:
            
            switch(indexPath.row)
            {
                case 0:
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

                    if(self.singletonObj.selectedAirlineIndex2 == -1)
                    {
                        cell.lblMenuItemLabel.text = @"Select an airline...";
                    }
                    else
                    {
                        cell.lblMenuItemLabel.text = @"Airline:";
                        cell.lblMenuItem.hidden = NO;
                        [cell.lblMenuItem setFrame:CGRectMake(75, cell.lblMenuItem.frame.origin.y, cell.lblMenuItem.frame.size.width, cell.lblMenuItem.frame.size.height)];
                        cell.lblMenuItem.text = self.singletonObj.selectedAirlineName2;
                    }
                    
                break;
                    
                case 1:
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                    
                    if(self.singletonObj.selectedOriginAirport.length > 0)
                    {
                        cell.lblMenuItemLabel.text = @"Origin:";
                        cell.lblMenuItem.hidden = NO;
                        [cell.lblMenuItem setFrame:CGRectMake((cell.lblMenuItem.frame.origin.x) - 27, cell.lblMenuItem.frame.origin.y, cell.lblMenuItem.frame.size.width, cell.lblMenuItem.frame.size.height)];
                        cell.lblMenuItem.text = self.singletonObj.selectedOriginAirport;
                    }
                    else
                    {
                        cell.lblMenuItemLabel.text = @"Select origin airport...";
                    }
                    
                break;
                    
                case 2:
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

                    if(self.singletonObj.selectedDestinationAirport.length > 0)
                    {
                        cell.lblMenuItemLabel.text = @"Destination:";
                        cell.lblMenuItem.hidden = NO;
                        [cell.lblMenuItem setFrame:CGRectMake((cell.lblMenuItem.frame.origin.x) + 7, cell.lblMenuItem.frame.origin.y, cell.lblMenuItem.frame.size.width, cell.lblMenuItem.frame.size.height)];
                        cell.lblMenuItem.text = self.singletonObj.selectedDestinationAirport;
                    }
                    else
                    {
                        cell.lblMenuItemLabel.text = @"Select destination airport...";
                    }
                    
                break;
                    
                case 3:
                    
                    [dateFormat1 setDateFormat:@"MMM dd yyyy - h:mm a"];
                
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

                    if(!self.singletonObj.didSelectDate)
                    {
                        cell.lblMenuItemLabel.text = @"Select departure date...";
                    }
                    else
                    {
                        cell.lblMenuItemLabel.text = @"Departure:";
                        cell.lblMenuItem.hidden = NO;
                        cell.lblMenuItem.text = [dateFormat1 stringFromDate:self.singletonObj.selectedDateIndex];
                    }
                    
                break;
                    
            }
            
        break;
            
    }
    
    return cell;
}

// cell click
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actSheet = [UIActionSheet alloc];
    self.selectedCell = (CheckFlightStatusCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    self.selectedPath = indexPath;
 
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
            
    }
}

// text field handler
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)doCheckStatus:(id)sender
{
    // make sure they have specified either a flight number or search parameters
    
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
        self.singletonObj.selectedFlightNo = cell2.inpMenuItem.text;
        [self performSegueWithIdentifier:@"segueFlightStatus" sender:self];
    }
    
}

// pass data to next view
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedRowIndex = [self.tableView indexPathForSelectedRow];
    self.singletonObj.destOrOriginSelected = (selectedRowIndex.row == 1) ? @"Origin" : @"Destination";
}

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
                    self.singletonObj.didSelectDate1 = (BOOL *)YES;
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
                        self.singletonObj.didSelectDate = (BOOL *)YES;
                        self.singletonObj.selectedDateIndex = [self.datePickerView date];
                }
            }

            [self.actSheet dismissWithClickedButtonIndex:0 animated:YES];
            
            if(self.selectedPath.row == 0)
            {
                
                self.selectedCell.lblMenuItemLabel.text = @"Airline:";
                self.selectedCell.lblMenuItem.hidden = NO;
                if(self.selectedCell.lblMenuItem.frame.origin.x != 75)
                {
                    [self.selectedCell.lblMenuItem setFrame:CGRectMake((self.selectedCell.lblMenuItem.frame.origin.x) - 25, self.selectedCell.lblMenuItem.frame.origin.y, self.selectedCell.lblMenuItem.frame.size.width, self.selectedCell.lblMenuItem.frame.size.height)];
                }
                self.selectedCell.lblMenuItem.text = [self.airlineNames objectAtIndex:[self.pickerView selectedRowInComponent:0]];
                
            }
            else if((self.selectedPath.section == 0 && self.selectedPath.row == 2) || (self.selectedPath.section == 1 && self.selectedPath.row == 3))
            {
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"MMM dd yyyy - h:mm a"];
                
                self.selectedCell.lblMenuItemLabel.text = @"Departure:";
                self.selectedCell.lblMenuItem.hidden = NO;
                
                if(self.selectedPath.row == 2)
                {
                    self.selectedCell.lblMenuItem.text = [dateFormat stringFromDate:self.singletonObj.selectedDateIndex1];
                }
                else
                {
                    self.selectedCell.lblMenuItem.text = [dateFormat stringFromDate:self.singletonObj.selectedDateIndex];
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

- (void)viewDidUnload {
    [self setBtnCheckStatus:nil];
    [self setLblMenuItem:nil];
    [super viewDidUnload];
}


@end
