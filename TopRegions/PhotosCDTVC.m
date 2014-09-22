//
//  PhotosCDTVC.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/17/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "PhotosCDTVC.h"
#import "Photo.h"
#import "ImageViewController.h"

@implementation PhotosCDTVC

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell of Photos"];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    cell.imageView.image = [UIImage imageWithData:photo.thumbnail];
    
    if (!cell.imageView.image) {
        dispatch_queue_t q = dispatch_queue_create("Flickr Photo Thumbnail", 0);
        dispatch_async(q, ^{
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]];
            [photo.managedObjectContext performBlock:^{
                photo.thumbnail = imageData;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell setNeedsDisplay];
                });
            }];
        });
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detailVc = [self.splitViewController.viewControllers lastObject];
    if ([detailVc isKindOfClass:[UINavigationController class]]) {
        detailVc = [((UINavigationController *)detailVc).viewControllers firstObject];
        [self prepareViewController:detailVc forSegue:nil fromIndexPath:indexPath];
    }
}

- (void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifier fromIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[ImageViewController class]]) {
        ImageViewController *ivc = (ImageViewController *) vc;
        ivc.imageURL = [NSURL URLWithString:photo.imageURL];
        ivc.title = photo.title;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    [self prepareViewController:segue.destinationViewController forSegue:segue.identifier fromIndexPath:indexPath];
}




@end
