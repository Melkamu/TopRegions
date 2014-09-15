//
//  ManagedDocumentHelper.m
//  TopRegions
//
//  Created by Melkamu A on 9/14/14.
//  Copyright (c) 2014 Nerdery. All rights reserved.
//

#import "ManagedDocumentHelper.h"

@interface ManagedDocumentHelper()
@property (nonatomic, strong) UIManagedDocument *managedDocument;
@property (nonatomic, assign) BOOL preparingDocument;
@end

#define DOCUMENT_NAME @"TopRegions"
#define RETRY_TIME_OUT 1.0

@implementation ManagedDocumentHelper

- (UIManagedDocument *)managedDocument
{
    if (!_managedDocument) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSURL *url = [documentDirectory URLByAppendingPathComponent:DOCUMENT_NAME];
        _managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    return _managedDocument;
}

+ (ManagedDocumentHelper *)managedDocumentHelperSingleton
{
    __strong static ManagedDocumentHelper *managedDocumentHelperSingleton = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        managedDocumentHelperSingleton = [[self alloc] init];
    });
    
    return managedDocumentHelperSingleton;
}

- (BOOL)checkAndSetPreparingDocument
{
    static dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("Flickr Document Helper Queue", NULL);
    }
    __block BOOL result = NO;
    dispatch_async(queue, ^{
        if (!_preparingDocument) {
            _preparingDocument = YES;
        } else {
            result = YES;
        }
    });
    
    return result;
}

+ (void)getManagedDocumentWhenReady:(void (^)(UIManagedDocument *, BOOL))documentReady
{
    ManagedDocumentHelper *dh = [ManagedDocumentHelper managedDocumentHelperSingleton];
    [dh getManagedDocument:documentReady];
}

- (void)getManagedDocument:(void (^)(UIManagedDocument *, BOOL))documentReady
{
    UIManagedDocument *document = self.managedDocument;
    
    if ([self checkAndSetPreparingDocument]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(getManagedDocument:) withObject:documentReady afterDelay:RETRY_TIME_OUT];
        });
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]) {
            [document openWithCompletionHandler:^(BOOL success) {
                self.preparingDocument = NO;
                if (success) {
                    documentReady(document, success);
                }
                if (!success) {
                    NSLog(@"Couldn't open document database at %@", document.fileURL);
                }
            }];
        } else {
            [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                self.preparingDocument = NO;
                if (success) {
                    documentReady(document, success);
                }
                if (!success) {
                    NSLog(@"Couldn't create document database at %@", document.fileURL);
                }
            }];
        }

    }
}
@end
