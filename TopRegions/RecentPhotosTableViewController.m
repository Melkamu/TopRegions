//
//  RecentPhotosTableViewController.m
//  TopPlaces
//
//  Created by Melkamu A on 9/9/14.
//  Copyright (c) 2014 melkam. All rights reserved.
//

#import "RecentPhotosTableViewController.h"
#import "FlickrFetcherHelper.h"

@interface RecentPhotosTableViewController ()

@end

@implementation RecentPhotosTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.photos = [FlickrFetcherHelper savedPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
