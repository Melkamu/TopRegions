//
//  TopRegionsAppDelegate.m
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/12/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "TopRegionsAppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"
#import "ManagedDocumentHelper.h"

@interface TopRegionsAppDelegate() <NSURLSessionDownloadDelegate>
@property (nonatomic, strong) NSManagedObjectContext *photoDatabaseContext;
@property (nonatomic, copy) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (nonatomic, strong) NSURLSession *flickrDownloadSession;
@property (nonatomic, strong) NSTimer *flickrForegroundFetcherTimer;
@end

#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

@implementation TopRegionsAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self createPhotoDatabaseContext];
    [self startFlickrFetch];
    return YES;
}

- (void)setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    _photoDatabaseContext = photoDatabaseContext;
    
    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext} : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification object:self userInfo:userInfo];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)localURL
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        NSManagedObjectContext *context = self.photoDatabaseContext;
        if (context) {
            NSArray *photos = [self flickrPhotosAtURL:localURL];
            [context performBlock:^{
                [self loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
                [context save:NULL];
            }];
        }
    } else {
        [self flickrDownloadTaskMightBeComplete];
    }
}

- (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)managedContext
{
    for (NSDictionary *photo in photos) {
        [Photo photoWithFlickrInfo:photo inManagedObjectContext:managedContext];
    }
    
    // query for region names
    [self loadRegionNamesInToManagedContext:managedContext];
}

- (void)loadRegionNamesInToManagedContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = nil;
    
    NSError *error;
    NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!matches && ![matches count]) {
        // do nothing
    } else {
        // query region names for all regions
    }
}



- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    NSDictionary *flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData options:0 error:NULL];
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

- (void)startFlickrFetch
{
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        }
    }];
}

- (NSURLSession *)flickrDownloadSession
{
    if (!_flickrDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH];
            urlSessionConfiguration.allowsCellularAccess = NO;
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration
                                                                   delegate:self delegateQueue:nil];
        });
    }
    
    return _flickrDownloadSession;
}

- (void)flickrDownloadTaskMightBeComplete
{
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                // no more download tasks left
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

- (void)createPhotoDatabaseContext
{
    [ManagedDocumentHelper getManagedDocumentWhenReady:^(UIManagedDocument *document, BOOL success) {
        if (success) {
            self.photoDatabaseContext = document.managedObjectContext;
        }
    }];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
