//
//  RegionNameDownloadHelper.h
//  TopRegions
//
//  Created by Melkamu Agonafer on 9/22/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegionNameDownloadHelper : NSObject
typedef void (^RegionNameDownloadCompletionHandler) (NSDictionary *regionInfo, void(^whenComplete)());
+ (void)startBackroundFetchRegionInfoForPlaceId:(NSString *)placeId onCompletion:(RegionNameDownloadCompletionHandler)completionHandler;
@end
