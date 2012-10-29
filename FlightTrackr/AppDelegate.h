//
//  AppDelegate.h
//  FlightTrackr
//
//  Created by Unbounded on 9/28/12.
//  Copyright (c) 2012 Scott Newman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define mainQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define GOOGLE_API_KEY @"AIzaSyDBJyj71kFr-gUWT1Om7FFo48fDSOIs5YY"
#define FLIGHT_AWARE_USERNAME @"snewman205"
#define FLIGHT_AWARE_KEY @"8aeb39a892fb8d7aa6129e70736bd4071a097430"
#define WUNDERGROUND_KEY @"6f2e49f628a37fc8"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define METERS_TO_FEET  3.2808399
#define FEET_CUTOFF     3281
#define FEET_IN_MILES   5280

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)resetCoreData;
- (NSPersistentStoreCoordinator *)resetPersistentStore;

@end
