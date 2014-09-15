//
//  ManagedDocumentHelper.h
//  TopRegions
//
//  Created by Melkamu A on 9/14/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManagedDocumentHelper : NSObject
+ (void)getManagedDocumentWhenReady:(void (^)(UIManagedDocument *document, BOOL success))documentReady;
@end
