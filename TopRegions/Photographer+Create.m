//
//  Photographer+Create.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+ (Photographer *)phototgrapherWithName:(NSString *)name inMangedObjectContext:(NSManagedObjectContext *)managedContext
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [managedContext executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count]) > 1) {
            // handle error
        } else if (![matches count]) {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:managedContext];
            photographer.name = name;
        } else {
            photographer = [matches lastObject];
        }
    }
    
    return photographer;
}

@end
