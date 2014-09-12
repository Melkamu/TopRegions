//
//  Photographer.h
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photosTaken;
@property (nonatomic, retain) Region *takesIn;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosTakenObject:(Photo *)value;
- (void)removePhotosTakenObject:(Photo *)value;
- (void)addPhotosTaken:(NSSet *)values;
- (void)removePhotosTaken:(NSSet *)values;

@end
