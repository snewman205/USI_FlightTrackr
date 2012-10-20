//
//  FavoriteAirports.m
//  FlightTrackr
//
//  Created by Unbounded on 10/11/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "FavoriteAirports.h"
#import "AirportSelectorResultsObj.h"
#import "CheckFlightStatus.h"

@interface FavoriteAirports ()

@end

@implementation FavoriteAirports

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    self.context = [self.appDelegate managedObjectContext];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Manage" style:UIBarButtonItemStyleDone target:self action:@selector(doEdit)];
    
    [self loadTableData];
}

#pragma mark - Table view data source

- (void)loadTableData
{
    
    self.airports = [NSMutableArray arrayWithCapacity:1];
    
    NSMutableArray *airportsTemp = [NSMutableArray arrayWithCapacity:1];
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteAirports"];
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    for(NSManagedObject *result in results)
    {
        AirportSelectorResultsObj *airport = [[AirportSelectorResultsObj alloc] init];
        airport.name = [result valueForKey:@"name"];
        airport.city = [result valueForKey:@"city"];
        airport.state = [result valueForKey:@"state"];
        airport.ident = [result valueForKey:@"identifier"];
        [airportsTemp addObject:airport];
    }
    
    for (AirportSelectorResultsObj *theAirport in airportsTemp)
    {
        
        NSInteger sect = [theCollation sectionForObject:theAirport collationStringSelector:@selector(name)];
        theAirport.sectionNumber = sect;
        
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    
    for (int i = 0; i < highSection; i++)
    {
        
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
        
    }
    
    for (AirportSelectorResultsObj *theAirport in airportsTemp)
    {
        
        [(NSMutableArray *)[sectionArrays objectAtIndex:theAirport.sectionNumber] addObject:theAirport];
        
    }
    
    for (NSMutableArray *sectionArray in sectionArrays)
    {
        
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(name)];
        [self.airports addObject:sortedSection];
        
    }
    
    if([results count] == 0)
    {
        [self.navigationItem setRightBarButtonItem:NULL];
        [self.tableView setEditing:NO animated:YES];
    }
    
    [self.tableView reloadData];

}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.airports objectAtIndex:section] count] > 0)
    {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
    
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.airports count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.airports objectAtIndex:section] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Remove";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = airportObj.name;
    cell.imageView.image = [UIImage imageNamed:@"07-map-marker.png"];
    cell.detailTextLabel.text = [airportObj.city stringByAppendingString:[@", " stringByAppendingString:airportObj.state]];
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"FavoriteAirports"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(identifier=%@)", airportObj.ident];
    NSError *error = nil;
    
    [request setPredicate:predicate];
        
    NSArray *results = [self.context executeFetchRequest:request error:&error];
    
    [self.context deleteObject:[results objectAtIndex:0]];
    [self.context save:&error];
    UIAlertView *msg = [[UIAlertView alloc] initWithTitle:@"Favorite Removed" message:[NSString stringWithFormat:@"%@ has been removed from your favorite airports", airportObj.name] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [msg show];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"segueCheckFlightStatus1" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    CheckFlightStatus *previousView = [[self.navigationController viewControllers] objectAtIndex:1];
    NSIndexPath *selCellPath = self.tableView.indexPathForSelectedRow;
    AirportSelectorResultsObj *airportObj = [[self.airports objectAtIndex:selCellPath.section] objectAtIndex:selCellPath.row];
    
    if([segue.identifier isEqualToString:@"segueCheckFlightStatus1"])
    {
     
        NSLog(@"testing branches");
        
        if([previousView.singletonObj.destOrOriginSelected isEqualToString:@"Origin"])
        {
            previousView.singletonObj.selectedOriginIdent = airportObj.ident;
            previousView.singletonObj.selectedOriginAirport = airportObj.name;
        }
        else
        {
            previousView.singletonObj.selectedDestinationIdent = airportObj.ident;
            previousView.singletonObj.selectedDestinationAirport = airportObj.name;
        }
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self loadTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doEdit
{
    if(self.tableView.editing)
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"Manage"];
        [self.tableView setEditing:NO animated:YES];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.tableView setEditing:YES animated:YES];
    }
}

@end
