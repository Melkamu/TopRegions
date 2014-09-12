//
//  Region+Create.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Region+Create.h"

@implementation Region (Create)
+ (Region *)regionWithId:(NSString *)regionId inManagedObjectContext:(NSManagedObjectContext *)managedContext
{
    Region *region = nil;
    
    if ([regionId length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"regionId = %@", regionId];
        
        NSError *error;
        NSArray *matches = [managedContext executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count]) > 1) {
            // handle error
        } else if (![matches count]) {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:managedContext];
            region.regionId = regionId;
        } else {
            region = [matches lastObject];
        }
    }
    
    return region;
}
@end
