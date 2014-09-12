//
//  Region+Create.h
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Region.h"

@interface Region (Create)
+ (Region *)regionWithId:(NSString *)regionId withPhotographer:(Photographer *)photographer inManagedObjectContext:(NSManagedObjectContext *)managedContext;
@end
