//
//  AirportSelector.m
//  FlightTrackr
//
//  Created by Unbounded on 9/29/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportSelector.h"
#import "AirportSelectorCell.h"
#import "AirportSelectorResults.h"

@interface AirportSelector ()

@end

@implementation AirportSelector

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

// view onLoad
- (void)viewDidLoad
{
    [super viewDidLoad];

    // init required variables
    self.sectionHeaders = [[NSArray alloc] initWithObjects:@"Browse by Identifier", @"Browse by Location", @"Favorites", nil];
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.indicator.center = self.view.center;
    self.airportDataPath = [[NSBundle mainBundle] pathForResource:@"Airports" ofType:@"plist"];
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
            numRows = 1;
        break;
        case 1:
            numRows = 2;
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
    static NSString *CellIdentifier = @"AirportSelectorCell";
    AirportSelectorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    switch(indexPath.section)
    {
        case 0:
            
            switch(indexPath.row)
        {
                
            case 0:
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.inpMenuItem.placeholder = @"EWR";
//                [cell.inpMenuItem addTarget:self action:@selector(textFieldShouldReturn) forControlEvents:UIControlEventEditingDidEndOnExit];
                cell.inpMenuItem.delegate = self;
                cell.inpMenuItem.hidden = NO;
                
            break;
                
        }
            
        break;
            
        case 1:
            
            switch(indexPath.row)
            {
                    
                case 0:
                    
                    cell.inpMenuItem.hidden = YES;
                    cell.lblMenuItemLabel.hidden = NO;
                    cell.lblMenuItemLabel.enabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.lblMenuItemLabel.text = @"Select a State...";
                    
                break;
                    
                case 1:
                    
                    cell.inpMenuItem.hidden = YES;
                    cell.lblMenuItemLabel.hidden = NO;
                    cell.lblMenuItemLabel.enabled = YES;
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    cell.lblMenuItemLabel.text = @"Select a City...";
                    
                break;
                    
            }
            
        break;
            
        case 2:
            
            cell.inpMenuItem.hidden = YES;
            cell.lblMenuItemLabel.hidden = NO;
            cell.lblMenuItemLabel.enabled = YES;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.lblMenuItemLabel.text = @"Choose from my favorites...";
            
        break;
                
    }
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.actSheet = [UIActionSheet alloc];
    self.selectedCell = (AirportSelectorCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    NSString *actionTitle = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    MainMenuSingleton *singletonObj = [MainMenuSingleton sharedInstance];
    
    switch(indexPath.section)
    {
        case 1:
            
            if(indexPath.row == 0)
            {
                actionTitle = @"Choose State";
                self.cityOrState = @"State";
            }
            else
            {
                actionTitle = @"Choose City";
                self.cityOrState = @"City";
            }
            
            // make sure the user selects a state first
            if(indexPath.row == 1 && self.didSelectState == NO)
            {
                UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select a State first" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
                [error show];
            }
            else
            {
            
                // set loading icon for cell
                [[self.tableView cellForRowAtIndexPath:indexPath] setAccessoryView:self.indicator];
                [self.indicator startAnimating];

                // configure & load action sheet picker
                self.actSheet = [self.actSheet initWithTitle:actionTitle delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose", nil];
                [self.actSheet showInView:self.view];
                [self.actSheet setFrame:CGRectMake(0, 80, 320, 383)];
                [self.actSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
                
            }
            
        break;
            
        case 2:
            
            if(indexPath.row == 0)
            {
                singletonObj.selectedFavorites = @"airports";
                [self performSegueWithIdentifier:@"segueFavoriteAirports" sender:self];
            }
    }
}

// actionsheet onLoad
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 140)];
    
    // Read & store airport data if we haven't already OR if we need to repopulate the city list
    if((self.stateNames == nil || self.cityNames == nil) || self.didStateChange)
    {
    
        NSMutableOrderedSet *airports = [[NSMutableOrderedSet alloc] init];
    
        self.airportDict = [[NSDictionary alloc] initWithContentsOfFile:self.airportDataPath];
        NSArray *tempArray = [self.airportDict objectForKey:@"Airports"];
        
        for (NSDictionary *airport in tempArray)
        {
            
            // if we're choosing a city, make sure we only display cities in the specified state
            if([self.cityOrState isEqualToString:@"City"])
            {
                
                if([[airport valueForKey:@"State"] isEqualToString:[self.stateNames objectAtIndex:(NSUInteger)self.selectedStateIndex]])
                {
                    [airports addObject:[airport valueForKey:self.cityOrState]];
                }
            }
            else
            {
                [airports addObject:[airport valueForKey:self.cityOrState]];
            }
        }
    
        // sort, sort, sort!
        if([self.cityOrState isEqualToString:@"State"] && self.stateNames == nil)
        {
            self.stateNames = [airports sortedArrayUsingComparator: ^(NSString* string1, NSString* string2)
                               {
                                   return [string1 localizedCompare: string2];
                               }];
        }
        else if([self.cityOrState isEqualToString:@"City"] && (self.cityNames == nil || self.didStateChange))
        {
            self.cityNames = [airports sortedArrayUsingComparator: ^(NSString* string1, NSString* string2)
                              {
                                  return [string1 localizedCompare: string2];
                              }];
        }
        
    }
    
    // some picker view config
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    
    NSInteger selIndex = 0;
    selIndex = [self.cityOrState isEqualToString:@"State"] ? self.selectedStateIndex : self.selectedCityIndex;
    [self.pickerView selectRow:selIndex inComponent:0 animated:0];
    
    //Add picker to action sheet
    [self.actSheet addSubview:self.pickerView];
    NSArray *subviews = [self.actSheet subviews];
    [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 216, 280, 46)];
    [[subviews objectAtIndex:2] setFrame:CGRectMake(20, 277, 280, 46)];
    [self.selectedCell setAccessoryView:nil];
    [self.selectedCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return ([self.cityOrState isEqualToString:@"State"]) ? [self.stateNames count] : [self.cityNames count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return ([self.cityOrState isEqualToString:@"State"]) ? [self.stateNames objectAtIndex:row] : [self.cityNames objectAtIndex:row];
}

// action sheet button click handler
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
            
            [self.actSheet dismissWithClickedButtonIndex:0 animated:YES];
            
            if([self.cityOrState isEqualToString:@"State"])
            {
                // update label to reflect chosen state
                self.selectedStateIndex = [self.pickerView selectedRowInComponent:0];
                self.selectedCell.lblMenuItemLabel.text = [self.stateNames objectAtIndex:(NSUInteger)[self.pickerView selectedRowInComponent:0]];
                if(!self.didSelectState)
                {
                    self.didSelectState = YES;
                }
                else
                {
                    // if we're choosing a different state, reset the city cell
                    self.didStateChange = YES;
                    self.selectedCityIndex = 0;
                    AirportSelectorCell *cityCell = (AirportSelectorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                    cityCell.lblMenuItemLabel.text = @"Select a City...";
                }
            }
            else
            {
                // update label to reflect chosen city
                self.selectedCityIndex = [self.pickerView selectedRowInComponent:0];
                self.selectedCell.lblMenuItemLabel.text = [self.cityNames objectAtIndex:(NSUInteger)[self.pickerView selectedRowInComponent:0]];
            }

            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
            
            break;
            
        case 1:
            
            [self.actSheet dismissWithClickedButtonIndex:1 animated:YES];
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
            
            break;
            
    }
}

// alert view button click handler
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidUnload {
    [self setInpMenuItem:nil];
    [self setLblMenuItemLabel:nil];
    [super viewDidUnload];
}
- (IBAction)doAirportSearch:(id)sender {
    
    AirportSelectorCell *selCell = (AirportSelectorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if(selCell.inpMenuItem.text.length == 0 && !self.didSelectState)
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please specify an airport identifier\nor location" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [error show];
    }
    else
    {
        [self performSegueWithIdentifier:@"segueAirportSelectorResults" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueAirportSelectorResults"])
    {
        AirportSelectorResults *dest = [segue destinationViewController];
        AirportSelectorCell *selCell1 = (AirportSelectorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        AirportSelectorCell *selCell2 = (AirportSelectorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        AirportSelectorCell *selCell3 = (AirportSelectorCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        dest.inpIdent = selCell1.inpMenuItem.text;
        dest.inpState = selCell2.lblMenuItemLabel.text;
        dest.inpCity = ([selCell3.lblMenuItemLabel.text isEqualToString:@"Select a City..."]) ? @"" : selCell3.lblMenuItemLabel.text;
    }
}
@end
