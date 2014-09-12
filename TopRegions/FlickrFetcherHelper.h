//
//  FlickrFetcherHelper.h
//  TopPlaces
//
//  Created by Melkamu A on 9/1/14.
//  Copyright (c) 2014 melkam. All rights reserved.
//

#import "FlickrFetcher.h"

@interface FlickrFetcherHelper : FlickrFetcher
+ (void)fetchTopPlaces:(void (^) (NSArray *topPlaces, NSError *error))onCompleteFetch;
+ (void)fetchPhotosForPlace:(NSDictionary *)place onComplete:(void (^) (NSArray *photos, NSError *error))onCompleteFetch;
+ (NSString *)cityOfPlace:(NSDictionary *)place;
+ (NSString *)stateOfPlace:(NSDictionary *)place;
+ (NSString *)countryOfPlace:(NSDictionary *)place;
+ (NSString *)photoTitle:(NSDictionary *)photo;
+ (NSString *)photoSubtitle:(NSDictionary *)photo;
+ (NSDictionary *)placesByCountries:(NSArray *)places;
+ (NSArray *)countries:(NSDictionary *)placesByCountries;
+ (NSArray *)savedPhotos;
+ (void)savePhoto:(NSDictionary *)photo;
@end
