//
//  Recent+Create.m
//  TopRegions
//
//  Created by Melkamu A on 9/14/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Recent+Create.h"

@implementation Recent (Create)

+ (Recent *)recentPhoto:(Photo *)photo
{
    Recent *recent = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo = %@", photo];
    NSError *error;
    NSArray *matches = [photo.managedObjectContext ]
}

@end
  