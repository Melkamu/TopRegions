//
//  RegionNameDownloadHelper.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/22/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "RegionNameDownloadHelper.h"
#import "FlickrFetcher.h"

@interface RegionNameDownloadHelper() <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSMutableDictionary *regionDownloadCompletionHandlers;
@property (nonatomic, copy) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (nonatomic, strong) NSURLSession *downloadSession;
@end

@implementation RegionNameDownloadHelper

#define FLICKR_REGION_FETCH @"flickr fetch region"
#define FLICKR_FETCH @"Flickr fetch"

- (NSMutableDictionary *)regionDownloadCompletionHandlers
{
    if (!_regionDownloadCompletionHandlers) {
        _regionDownloadCompletionHandlers = [[NSMutableDictionary alloc] init];
    }
    return _regionDownloadCompletionHandlers;
}

- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            urlSessionConfiguration.allowsCellularAccess = NO;
            _downloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration
                                                                   delegate:self delegateQueue:nil];
        });
    }
    
    return _downloadSession;
}

+ (RegionNameDownloadHelper *)regionNameDownloadHelperSingleton
{
    static dispatch_once_t pred = 0;
    __strong static RegionNameDownloadHelper *_reginNameDownloadHelperSingleton = nil;
    dispatch_once(&pred, ^{
        _reginNameDownloadHelperSingleton = [[self alloc] init];
    });
    return _reginNameDownloadHelperSingleton;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_REGION_FETCH]) {
        NSDictionary *flickrRegionPropertyList;
        NSData *flickrRegionJSONData = [NSData dataWithContentsOfURL:location];
        if (flickrRegionJSONData) {
            flickrRegionPropertyList = [NSJSONSerialization JSONObjectWithData:flickrRegionJSONData options:0 error:NULL];
        }
        RegionNameDownloadCompletionHandler completionHandler = [self.regionDownloadCompletionHandlers[[NSString stringWithFormat:@"%lu", (unsigned long)downloadTask.taskIdentifier]] copy];
        if (completionHandler) {
            completionHandler(flickrRegionPropertyList, ^{
                [self downloadTasksMightBeComplete];
            });
        }
        [self.regionDownloadCompletionHandlers removeObjectForKey:@(downloadTask.taskIdentifier)];
    }
}

- (void)downloadTasksMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        NSURLSession *session = self.downloadSession;
        [session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler) () = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

+ (void)startBackroundFetchRegionInfoForPlaceId:(NSString *)placeId onCompletion:(RegionNameDownloadCompletionHandler)completionHandler
{
    RegionNameDownloadHelper *regionNameDownloadHelper = [RegionNameDownloadHelper regionNameDownloadHelperSingleton];
    NSURLSession *regionDownloadSesison = regionNameDownloadHelper.downloadSession;
    [regionDownloadSesison getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSURLSessionDownloadTask *task = [regionDownloadSesison downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeId]];
        task.taskDescription = FLICKR_REGION_FETCH;
        [regionNameDownloadHelper.regionDownloadCompletionHandlers setObject:[completionHandler copy] forKey:[NSString stringWithFormat:@"%lu", (unsigned long)task.taskIdentifier]];
        [task resume];
    }];
}

@end
