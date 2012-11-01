//
//  AirportLocalPlacesList.m
//  FlightTrackr
//
//  Created by Unbounded on 10/24/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import "AirportLocalPlacesList.h"

@interface AirportLocalPlacesList ()

@end

@implementation AirportLocalPlacesList

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView setScrollEnabled:NO];
    [self loadTableData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnDismiss:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)loadTableData
{
    self.places = [NSMutableArray arrayWithCapacity:1];
    
    self.placesTemp = [NSMutableArray arrayWithCapacity:1];
    UILocalizedIndexedCollation *theCollation = [UILocalizedIndexedCollation currentCollation];
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    for(int i = 0; i < [singletonObj.localPlacesResults count]; i++)
    {
        LocalPlacesObject *placeObj = [[LocalPlacesObject alloc] init];
        NSDictionary *place = [singletonObj.localPlacesResults objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        NSDictionary *location = [geo objectForKey:@"location"];
        NSString *name = [place objectForKey:@"name"];
        NSString *vicinity = [place objectForKey:@"vicinity"];
        NSString *ref = [place objectForKey:@"reference"];
        CLLocationCoordinate2D placeCoordinate;
        
        placeCoordinate.latitude = [[location objectForKey:@"lat"] doubleValue];
        placeCoordinate.longitude = [[location objectForKey:@"lng"] doubleValue];
        
        placeObj.name = name;
        placeObj.address = vicinity;
        placeObj.coord = placeCoordinate;
        placeObj.ref = ref;
        
        [self.placesTemp addObject:placeObj];
    }
    
    for (LocalPlacesObject *thePlace in self.placesTemp)
    {
        
        NSInteger sect = [theCollation sectionForObject:thePlace collationStringSelector:@selector(name)];
        thePlace.sectionNumber = sect;
        
    }
    
    NSInteger highSection = [[theCollation sectionTitles] count];
    NSMutableArray *sectionArrays = [NSMutableArray arrayWithCapacity:highSection];
    
    for (int i = 0; i < highSection; i++)
    {
        
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sectionArrays addObject:sectionArray];
        
    }
    
    for (LocalPlacesObject *thePlace in self.placesTemp)
    {
        
        [(NSMutableArray *)[sectionArrays objectAtIndex:thePlace.sectionNumber] addObject:thePlace];
        
    }
    
    for (NSMutableArray *sectionArray in sectionArrays)
    {
        
        NSArray *sortedSection = [theCollation sortedArrayFromArray:sectionArray
                                            collationStringSelector:@selector(name)];
        [self.places addObject:sortedSection];
        
    }
    
    [self.tableView setScrollEnabled:YES];
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[self.places objectAtIndex:section] count] > 0)
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
    return [self.places count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.places objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    LocalPlacesObject *placeObj = [[self.places objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:singletonObj.airportLocation.latitude longitude:singletonObj.airportLocation.longitude];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:placeObj.coord.latitude longitude:placeObj.coord.longitude];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    float distanceConv = distance * METERS_TO_FEET;
    NSString *format;
    
    if (distanceConv < FEET_CUTOFF)
    {
        format = @"%.1f feet";
    } else {
        format = @"%.1f miles";
        distanceConv = distanceConv / FEET_IN_MILES;
    }
    
    cell.textLabel.text = [placeObj.name length] > 15 ? [NSString stringWithFormat:@"%@...", [placeObj.name substringToIndex:15]] : placeObj.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:format, distanceConv];
    
    return cell;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocalPlacesObject *placeObj = [[self.places objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    AirportSingleton *singletonObj = [AirportSingleton sharedInstance];
    
    singletonObj.googleRef = placeObj.ref;
    
    [self dismissModalViewControllerAnimated:NO];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
