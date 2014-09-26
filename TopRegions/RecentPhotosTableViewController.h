//
//  RecentPhotosTableViewController.h
//  TopPlaces
//
//  Created by Melkamu A on 9/9/14.
//  Copyright (c) 2014 melkam. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RecentPhotosTableViewController : CoreDataTableViewController
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
