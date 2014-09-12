//
//  Photographer+Create.h
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)
+ (Photographer *)phototgrapherWithName:(NSString *)name inMangedObjectContext:(NSManagedObjectContext *)managedContext;
@end
