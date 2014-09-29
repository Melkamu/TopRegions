//
//  RecentPhotosTableViewController.h
//  TopPlaces
//
//  Created by Melkamu A on 9/9/14.
//  Copyright (c) 2014 melkam. All rights reserved.
//

#import "PhotosCDTVC.h"

@interface RecentPhotosTableViewController : PhotosCDTVC
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end
