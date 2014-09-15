//
//  Photo+Flickr.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Region+Create.h"

@implementation Photo (Flickr)
+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)managedContext
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [managedContext executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
    } else if ([matches count]) {
        photo = [matches lastObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:managedContext];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.takenBy = [Photographer phototgrapherWithName:photographerName inMangedObjectContext:managedContext];
        NSString *placeId = [photoDictionary valueForKeyPath:FLICKR_PHOTO_PLACE_ID];
        photo.takenIn = [Region regionWithId:placeId withPhotographer:photo.takenBy inManagedObjectContext:managedContext];
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)managedContext
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:managedContext];
    }
}

@end
