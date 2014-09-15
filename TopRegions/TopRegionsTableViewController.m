//
//  TopRegionsTableViewController.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "TopRegionsTableViewController.h"
#import "Region.h"
#import "PhotoDatabaseAvailability.h"

@interface TopRegionsTableViewController ()

@end

@implementation TopRegionsTableViewController

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification object:nil queue:nil usingBlock:^ (NSNotification *notification) {
        self.managedObjectContext = notification.userInfo[PhotoDatabaseAvailabilityContext];
    }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
    request.fetchLimit = 50;
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil cacheName:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Regions Cell"];
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photos by %@ photographers.", region.photos , region.photographers];
    return cell;
}

@end
