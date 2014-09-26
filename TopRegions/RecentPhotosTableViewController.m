//
//  RecentPhotosTableViewController.m
//  TopPlaces
//
//  Created by Melkamu A on 9/9/14.
//  Copyright (c) 2014 melkam. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "FlickrFetcherHelper.h"
#import "PhotoDatabaseAvailability.h"

@interface RecentPhotosTableViewController ()

@end

@implementation RecentPhotosTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
    }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest  *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"recent != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recent.created" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

@end
