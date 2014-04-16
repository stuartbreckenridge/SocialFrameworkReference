//
//  TWBFlickrViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 15/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
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
 There are no public Social Framework methods available for Flickr. The alternative is to use UIActivityViewController, as is demonstrated below, which subsequently presents an SLComposeViewController.
 @warning If there is no Flickr account setup, the UIActivityViewController appears with a cancel option only.
 */
-(IBAction)postImageToFlickr:(id)sender
{
    UIActivityViewController *flickrController = ({
        // Get the UIImage
        UIImage *flickrImage   = [UIImage imageNamed:@"FlickrImage"];
        NSString *imageString  = @"I love satay!";
        NSArray *activityItems = @[flickrImage, imageString];
        flickrController       = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
        flickrController.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypeMail, UIActivityTypeMessage, UIActivityTypePostToFacebook, UIActivityTypePostToTencentWeibo, UIActivityTypePostToTwitter, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypeAirDrop];
        
        flickrController;
    });
    
    [self presentViewController:flickrController animated:YES completion:^{
        //
    }];

    // Memory Management
    flickrController = nil;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
