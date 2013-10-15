//
//  TWBFlickrViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 15/10/2013.
//  Copyright (c) 2013 TheWorkingBear. All rights reserved.
//

#import "TWBFlickrViewController.h"
@import Social;

@interface TWBFlickrViewController ()

@end

@implementation TWBFlickrViewController

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

#pragma mark - Image Posting To Flickr With UIActivityViewController
/**
 There are no Social Framework methods available for flickr. The alternative is to use UIActivityViewController, as is demonstrated below.
 */
-(IBAction)postImageToFlickr:(id)sender
{
    // Get the UIImage
    UIImage *flickrImage = [UIImage imageNamed:@"FlickrImage"];
    NSArray *activityItems = @[flickrImage];
    
    UIActivityViewController *flickrController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    flickrController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToFacebook, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypeAirDrop];
    
    [self presentViewController:flickrController animated:YES completion:^{
        //
    }];
    
    flickrImage = nil;
    activityItems = nil;
    flickrController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
