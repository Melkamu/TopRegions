//
//  Region.h
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSString * regionId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * photographers;
@property (nonatomic, retain) NSNumber * photos;
@property (nonatomic, retain) NSSet *photosIn;
@property (nonatomic, retain) NSSet *takersIn;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotosInObject:(Photo *)value;
- (void)removePhotosInObject:(Photo *)value;
- (void)addPhotosIn:(NSSet *)values;
- (void)removePhotosIn:(NSSet *)values;

- (void)addTakersInObject:(Photographer *)value;
- (void)removeTakersInObject:(Photographer *)value;
- (void)addTakersIn:(NSSet *)values;
- (void)removeTakersIn:(NSSet *)values;

@end
