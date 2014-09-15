//
//  Recent+Create.m
//  TopRegions
//
//  Created by Melkamu A on 9/14/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Recent+Create.h"
#import "Photo.h"

@implementation Recent (Create)

#define MAXIMUM_RECENT_PHOTOS 20

+ (Recent *)recentPhoto:(Photo *)photo
{
    Recent *recent = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo = %@", photo];
    NSError *error;
    NSArray *matches = [photo.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1) {
        // handler error
    } else if (![matches count]) {
        recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:photo.managedObjectContext];
        recent.photo = photo;
        recent.created = [NSDate date];
        
//        request.predicate = nil;
//        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
//        
//        matches = [photo.managedObjectContext executeFetchRequest:request error:&error];
//        
//        if ([matches count] > MAXIMUM_RECENT_PHOTOS) {
//            [photo.managedObjectContext deleteObject:[matches lastObject]];
//        }
        
    } else {
        recent = [matches lastObject];
        recent.created = [NSDate date];
    }
    
    return recent;
}

@end
  