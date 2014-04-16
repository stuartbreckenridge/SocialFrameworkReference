//
//  TWBTwitterViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 10/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import "TWBTwitterViewController.h"
#import "TWBTwitterFriendsViewController.h"
#import "TWBSocialHelper.h"
#import "MBProgressHUD.h"

@interface TWBTwitterViewController ()

/**
 UIButton used for selecting the specific Twitter Account that the user wants to use.
 */
@property (nonatomic, weak) IBOutlet UIButton * accountSelector;
@property (nonatomic, strong) TWBSocialHelper * localInstance;
@property (nonatomic, strong) MBProgressHUD   * theHud;

@end

@implementation TWBTwitterViewController


#pragma mark - View Loading
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Request Access to Twitter Accounts
    [self requestAccessToTwitter];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (_localInstance.twitterAccessGranted) {
        _accountSelector.titleLabel.text = [NSString stringWithFormat:@"@%@", _localInstance.twitterAccount.username];
    } else
    {
        _accountSelector.titleLabel.text = @"Select Account";
    }
    
}

#pragma mark - Twitter Access
-(void)requestAccessToTwitter
{
    _localInstance = [TWBSocialHelper sharedHelper];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_localInstance requestAccessToTwitterAccounts];
    });
}

#pragma mark - Twitter Posting Methods
/**
 This method will post a predetermined string to Twitter using the account specified in the Tweet Sheet.
 */
- (IBAction)postTextWithSLComposeViewController:(id)sender
{
    // Confirm that a Twitter account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        // Create a compose view controller for the service type Twitter
        SLComposeViewController *postTweetWithText = ({
            postTweetWithText = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            // Set the text of the tweet
            [postTweetWithText setInitialText:@"This is test tweet with text only."];
            
            // Set the completion handler to check the result of the post.
            [postTweetWithText setCompletionHandler:^(SLComposeViewControllerResult result){
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Compose Result: Post Cancelled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Compose Result: Post Done");
                    default:
                        break;
                }}];
            
            postTweetWithText;
        });
        
        // Display the tweet sheet to the user
        [self presentViewController:postTweetWithText animated:YES completion:nil];
        
        //Memory Management
        postTweetWithText = nil;
    }
    
    else
    {
        UIAlertView *twitterAlert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Access to the Twitter accounts has not been given; or there are no Twitter accounts available." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [twitterAlert show];
        
        // Memory Management
        twitterAlert = nil;
    }
}

/**
 This method will post a predetermined string and image from the App Bundle to Twitter using the account specified in the Tweet Sheet.
 */
- (IBAction)postTextAndImageWithSLComposeViewController:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        // Create a compose view controller for the service type Twitter
        SLComposeViewController *postTweetWithTextAndImage = ({
            // Create a compose view controller for the service type Twitter
            postTweetWithTextAndImage = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            // Set the text of the tweet
            [postTweetWithTextAndImage setInitialText:@"This is a test tweet with text and an image."];
            
            // Set the image to be used in the tweet. For ease of use, this uses an image contained in the app bundle.
            [postTweetWithTextAndImage addImage:[UIImage imageNamed:@"FlickrImage"]];
            
            // Set the completion handler to check the result of the post.
            [postTweetWithTextAndImage setCompletionHandler:^(SLComposeViewControllerResult result){
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Compose Result: Post Cancelled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Compose Result: Post Done");
                    default:
                        break;
                }}];
            
            postTweetWithTextAndImage;
        });
        
        // Display the tweet sheet to the user
        [self presentViewController:postTweetWithTextAndImage animated:YES completion:nil];
        
        //Memory Management
        postTweetWithTextAndImage = nil;
    }
    
    else
    {
        UIAlertView *twitterAlert = [[UIAlertView alloc] initWithTitle:@"Twitter Error" message:@"Access to the Twitter accounts has not been given; or there are no Twitter accounts available." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [twitterAlert show];
        
        // Memory Management
        twitterAlert = nil;
    }
}

/**
 This method posts a predetermined string using SLRequest. The account used for the reqeust is specified by the user at the top of the UI.
 */
- (IBAction)postTextWithSLRequest:(id)sender {
    
    [self showHud];
    
    SLRequest *postTweetToTwitter = ({
        // Set the Twitter URL endpoint
        NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
        
        // Set the tweet message
        NSDictionary *tweetDetails = @{@"status": @"This is a test tweet. Thanks #Stuart Breckenridge."};
        
        postTweetToTwitter = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:twitterPostURL
                                                   parameters:tweetDetails];
        
        // Set the Twitter account to use.
        [postTweetToTwitter setAccount:_localInstance.twitterAccount];
        
        // Perform the request
        [postTweetToTwitter performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             // The output of the request is placed in the log.
             NSLog(@"HTTP Response: %li", (long)[urlResponse statusCode]);
             
             if ([urlResponse statusCode] == 200) {
                 
                 [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
                 [self performSelectorOnMainThread:@selector(presentSuccessAlert) withObject:nil waitUntilDone:NO];
             }
             
             if (error) {
                 [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
                 NSLog(@"There was an error:%@", [error localizedDescription]);
             }
         }];
        
        postTweetToTwitter;
    });
    
    // Memory Management
    postTweetToTwitter = nil;
}

- (IBAction)postTextAndImageWithSLRequest:(id)sender {
    // Set the Twitter URL endpoint
    [self showHud];
   
    SLRequest *postTweetToTwitter = ({
        // Set the Twitter URL endpoint
        NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
        
        // Set the tweet message
        NSDictionary *tweetDetails = @{@"status": @"This is a test tweet. Thanks #Stuart Breckenridge."};
        
        // Get the image from the app bundle
        UIImage *image = [UIImage imageNamed:@"FlickrImage"];
        NSData *data = UIImageJPEGRepresentation(image, 0.5f);
        
        // Create the Request
        postTweetToTwitter = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                requestMethod:SLRequestMethodPOST
                                                          URL:twitterPostURL
                                                   parameters:tweetDetails];
        
        // Add the image to the Tweet
        [postTweetToTwitter addMultipartData:data
                                    withName:@"media[]"
                                        type:@"image/jpeg"
                                    filename:@"image.jpg"];
        
        // Set the Twitter account to use.
        [postTweetToTwitter setAccount:_localInstance.twitterAccount];
        
        // Perform the request
        [postTweetToTwitter performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             // The output of the request is placed in the log.
             NSLog(@"HTTP Response: %li", (long)[urlResponse statusCode]);
             
             if ([urlResponse statusCode] == 200) {
                 
                 [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
                 [self performSelectorOnMainThread:@selector(presentSuccessAlert) withObject:nil waitUntilDone:NO];
             }
             
             if (error) {
                 [self performSelectorOnMainThread:@selector(hideHud) withObject:nil waitUntilDone:NO];
                 NSLog(@"There was an error:%@", [error localizedDescription]);
             }
         }];
        
        // Memory management
        image = nil;
        data = nil;
        
        postTweetToTwitter;
    });
    
    // Memory Management
    postTweetToTwitter = nil;
}




#pragma mark - UIAlerts
-(void)presentSuccessAlert
{
    UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"Success" message:@"The Twitter request was successful." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [success show];
    
    // Memory Management
    success = nil;
}

#pragma mark - ProgressHud
-(void)showHud
{
    if (_theHud == nil) {
        _theHud = [[MBProgressHUD alloc] init];
    }
    
    _theHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _theHud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    _theHud.labelText = @"Posting";
}

-(void)hideHud
{
    [_theHud hide:YES];
}

#pragma mark - Memory Warnings
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
