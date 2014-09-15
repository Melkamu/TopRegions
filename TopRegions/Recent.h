//
//  Recent.h
//  TopRegions
//
//  Created by Melkamu A on 9/14/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) Photo *photo;

@end
