//
//  FlickrFetcherHelper.m
//  TopPlaces
//
//  Created by Melkamu A on 9/1/14.
//  Copyright (c) 2014 melkam. All rights reserved.
//

#import "FlickrFetcherHelper.h"
#import "FlickrFetcher.h"

@implementation FlickrFetcherHelper

+ (void)fetchTopPlaces:(void (^)(NSArray *, NSError *))onCompleteFetch
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLforTopPlaces]];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *requestUrl, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:requestUrl];
            NSArray *topPlaces = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]
                                  valueForKeyPath:FLICKR_RESULTS_PLACES];
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleteFetch(topPlaces, error);
            });
            
        }
    }];
    [downloadTask resume];
}

+ (void)fetchRecentPhotosOnComplete:(void (^) (NSArray *places, NSError *error))onCompleteFetch
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    configuration.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos] completionHandler:^(NSURL *requestURL, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:requestURL];
            NSArray *recentPhotos = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleteFetch(recentPhotos, error);
            });
        }
    }];
    [downloadTask resume];
}

+ (void)fetchPhotosForPlace:(NSDictionary *)place onComplete:(void (^)(NSArray *, NSError *))onCompleteFetch
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLforPhotosInPlace:[place valueForKeyPath:FLICKR_PLACE_ID] maxResults:50]];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL *requestUrl, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData *data = [NSData dataWithContentsOfURL:requestUrl];
            NSArray *photos = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
            dispatch_async(dispatch_get_main_queue(), ^{
                onCompleteFetch(photos, error);
            });
        }
    }];
    [downloadTask resume];
}

+ (NSString *)cityOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "] firstObject];
}

+ (NSString *)stateOfPlace:(NSDictionary *)place
{
    NSArray *placeNameStrings = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    return [placeNameStrings objectAtIndex:1];
}

+ (NSString *)countryOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "] lastObject];
}

#define UNKNOWN_PHOTO_TITLE @"Unknown"

+ (NSString *)photoTitle:(NSDictionary *)photo
{
    NSString *title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    if (![title length]) {
        title = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        if (![title length]) {
            title = UNKNOWN_PHOTO_TITLE;
        }
    }
    return title;
}

+ (NSString *)photoSubtitle:(NSDictionary *)photo
{
    NSString *subtitle = [photo valueForKey:FLICKR_PHOTO_DESCRIPTION];
    if (![subtitle length]) {
        subtitle = UNKNOWN_PHOTO_TITLE;
    }
    return subtitle;
}

+ (NSDictionary *)placesByCountries:(NSArray *)places
{
    NSMutableDictionary *placesByCountries = [NSMutableDictionary dictionary];
    
    for (NSDictionary *place in places) {
        NSString *countryName = [FlickrFetcherHelper countryOfPlace:place];
        NSMutableArray *placesOfContry = placesByCountries[countryName];
        if (!placesOfContry) {
            placesOfContry = [NSMutableArray array];
        }
        [placesOfContry addObject:place];
        placesByCountries[countryName] = placesOfContry;
    }
    
    return placesByCountries;
}

+ (NSArray *)countries:(NSDictionary *)placesByCountries
{
    NSArray *countries = [placesByCountries allKeys];
    countries = [countries sortedArrayUsingSelector:@selector(compare:)];
    return countries;
}

#define RECENT_PHOTOS_ID @"Recent photos"

+ (NSArray *)savedPhotos
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS_ID];
}

+ (void)savePhoto:(NSDictionary *)photo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photos = [[userDefaults objectForKey:RECENT_PHOTOS_ID] mutableCopy];
    
    if (!photos) {
        photos = [NSMutableArray array];
    }
    NSUInteger key = NSNotFound;
    for (NSDictionary *savedPhoto in photos) {
        if ([savedPhoto isEqualToDictionary:photo]) {
            key = [photos indexOfObject:savedPhoto];
        }
    }
    
    if (key != NSNotFound) {
        [photos removeObjectAtIndex:key];
    }
    
    [photos insertObject:photo atIndex:0]; // place it first
    
    [userDefaults setObject:photos forKey:RECENT_PHOTOS_ID];
    [userDefaults synchronize];
}

@end
