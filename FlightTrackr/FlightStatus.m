//
//  FlightStatus.m
//  FlightTrackr
//
//  Created by Unbounded on 10/15/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FlightStatus.h"

#define mainQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface FlightStatus ()

@end

@implementation FlightStatus

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.sectionHeaders = [NSArray arrayWithObjects:@"Status", @"", nil];
    self.previousView = [[self.navigationController viewControllers] objectAtIndex:1];
    
    NSURL *jsonURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://snewman205:83b6981ad05f1772d1a3c4dae8539a65938d44de@flightxml.flightaware.com/json/FlightXML2/FlightInfo?ident=%@%@&howMany=1", self.previousView.singletonObj.selectedAirlineIdent1, self.previousView.singletonObj.selectedFlightNo]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    dispatch_async(mainQueue, ^
                   {
                       NSData *data = [NSData dataWithContentsOfURL:jsonURL];
                       
                       [self performSelectorOnMainThread:@selector(dataRetreived:) withObject:data waitUntilDone:YES];
                   });

}

- (void)dataRetreived:(NSData*)dataResponse
{
    
    NSError *error;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataResponse options:kNilOptions error:&error];
    
    NSDictionary *allData = [jsonDict objectForKey:@"FlightInfoResult"];
    
    NSArray *returnedFlightInfo = [allData objectForKey:@"flights"];
    self.flightInfo = [returnedFlightInfo objectAtIndex:0];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    switch(section)
    {
        case 0:
            return 1;
        break;
        
        case 1:
            return 1;
        break;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            // Configure the cell...
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = @"En Route";
        
            return cell;
        
    }
    
    else
    {
        
        static NSString *CellIdentifier = @"Cell1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        switch(indexPath.section)
        {
            case 1:
                
                switch(indexPath.row)
                {
                    case 0:
                        
                        cell.textLabel.text = @"Departing:";
                        cell.detailTextLabel.text = @"soon";
                        
                    break;
                }
                
            break;
        }
        
        return cell;
        
    }
    
    return NULL;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
