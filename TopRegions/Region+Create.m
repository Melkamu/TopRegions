//
//  Region+Create.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Region+Create.h"
#import "FlickrFetcherHelper.h"
#import "RegionNameDownloadHelper.h"
#import "FlickrFetcher.h"

@implementation Region (Create)

+ (Region *)regionWithId:(NSString *)regionId withPhotographer:(Photographer *)photographer inManagedObjectContext:(NSManagedObjectContext *)managedContext
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
            region.photos = @1;
            region.photographers = @1;
            [region addTakersInObject:photographer];
            
        } else {
            region = [matches lastObject];
            region.photos = @([region.photos intValue] + 1);
            if (![region.takersIn member:photographer]) {
                [region addTakersInObject:photographer];
                region.photographers = @([region.photographers intValue] + 1);
            }
        }
    }
    
    return region;
}

+ (void)loadRegionNamesInToManagedContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name.length = %@", nil];
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches || ![matches count]) {
        // do nothing
    } else {
        for (Region *match in matches) {
            
            [RegionNameDownloadHelper startBackroundFetchRegionInfoForPlaceId:match.regionId onCompletion:^(NSDictionary *regionInfo, void (^whenComplete)()) {
                if (managedObjectContext) {
                    [managedObjectContext performBlock:^{
                        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:regionInfo];
                        
                        match.name = regionName;
                        
                        if (whenComplete) {
                            whenComplete();
                        }
                    }];
                } else if (whenComplete) {
                    whenComplete();
                }
            }];
        }
        
    }
}


@end
