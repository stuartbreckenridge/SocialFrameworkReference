//
//  TWBFacebookViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 10/10/2013.
//  Copyright (c) 2013 TheWorkingBear. All rights reserved.
//

#import "TWBFacebookViewController.h"
#import "TWBSocialHelper.h"
#import "MBProgressHUD.h"

@interface TWBFacebookViewController ()

@property (nonatomic) TWBSocialHelper *localInstance;

/**
 This UILabel displays the full name of the logged in Facebook user, if access has been granted. Otherwise, it defaults to "User Not Logged In".
 */
@property (weak, nonatomic) IBOutlet UILabel *accountName;

@property (nonatomic) MBProgressHUD *theHud;

@end

@implementation TWBFacebookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // Register for access notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAccountName)
                                                 name:@"ReadAccessGranted"
                                               object:nil];
    
    _localInstance = [TWBSocialHelper sharedHelper];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [_localInstance requestReadAccessToFacebook];
    });
}

-(void)updateAccountName
{
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    _accountName.text = _localInstance.facebookAccount.userFullName;
    });
}

#pragma mark - Facebook - SLComposeViewController
-(IBAction)postTextWithSLComposeViewController
{
    // Confirm that a Facebook account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        // Create a compose view controller for the service type Facebook
        SLComposeViewController *postToWallWithText = ({
        
            postToWallWithText = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            // Set the text of the post
            [postToWallWithText setInitialText:@"This is test post with text only."];
            
            // Set the completion handler to check the result of the post.
            [postToWallWithText setCompletionHandler:^(SLComposeViewControllerResult result){
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Compose Result: Canelled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Compose Result: Done");
                    default:
                        break;
                }}];
            
            // Display the post sheet to the user
            [self presentViewController:postToWallWithText animated:YES completion:nil];
            
            postToWallWithText;
        });
        
        // Memory Management
        postToWallWithText = nil;
    }
    
    else
    {
        UIAlertView *facebookAlert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Access to the Facebook account has not been given; or there is no Facebook account available." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [facebookAlert show];
        
        // Memory Management
        facebookAlert = nil;
    }
}

#pragma mark - Method 1 - Post Text and Image with SLComposeViewController
-(IBAction)postTextAndImageWithSLComposeViewController
{
    // Confirm that a Facebook account exists
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        // Create a compose view controller for the service type Facebook
        SLComposeViewController *postToWallWithTextAndImage = ({
            
            postToWallWithTextAndImage = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            // Set the text & Image of the post
            [postToWallWithTextAndImage setInitialText:@"This is test post with text and an image."];
            [postToWallWithTextAndImage addImage:[UIImage imageNamed:@"FlickrImage"]];
            
            // Set the completion handler to check the result of the post.
            [postToWallWithTextAndImage setCompletionHandler:^(SLComposeViewControllerResult result){
                switch (result) {
                    case SLComposeViewControllerResultCancelled:
                        NSLog(@"Compose Result: Canelled");
                        break;
                    case SLComposeViewControllerResultDone:
                        NSLog(@"Compose Result: Done");
                    default:
                        break;
                }}];
            
            // Display the post sheet to the user
            [self presentViewController:postToWallWithTextAndImage animated:YES completion:nil];
            
            postToWallWithTextAndImage;
        });
        
        // Memory Management
        postToWallWithTextAndImage = nil;
    }
    
    else
    {
        UIAlertView *facebookAlert = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"Access to the Facebook account has not been given; or there is no Facebook account available." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [facebookAlert show];
        
        // Memory Management
        facebookAlert = nil;
    }
}

-(IBAction)updateWallWithSLRequest
{
    [self showHud];
    
    // Check that various permissions have been granted
    if (!_localInstance.readAccessGranted) {
        [_localInstance requestReadAccessToFacebook];
    }
    
    if (!_localInstance.writeAccessGranted) {
        [_localInstance requestWriteAccessToFacebook];
    }
    
    // Only if read and write permissions are granted is the post request performed
    if (_localInstance.readAccessGranted && _localInstance.writeAccessGranted)
    {
        // Create the SLRequest
        SLRequest *postToMyWall = ({
            // Create an NSURL pointing the correct open graph end point
            NSURL *postURL = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
            
            // Create the post details
            NSString *link = @"https://github.com/theworkingbear/SocialFrameworkReference";
            NSString *message = @"Testing Social Framework Reference for iOS 7";
            NSString *picture = @"http://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/150px-Apple_logo_black.svg.png";
            NSString *name = @"Social Framework";
            NSString *caption = @"GitHub";
            NSString *description = @"The Social framework lets you integrate your app with supported social networking services. On iOS and OS X, this framework provides a template for creating HTTP requests. On iOS only, the Social framework provides a generalized interface for posting requests on behalf of the user.";
            
            // Create a dictionary of post elements
            NSDictionary *postDict = @{
                                       @"link": link,
                                       @"message" : message,
                                       @"picture" : picture,
                                       @"name" : name,
                                       @"caption" : caption,
                                       @"description" : description
                                       };

            
            postToMyWall = [SLRequest requestForServiceType:SLServiceTypeFacebook
                               requestMethod:SLRequestMethodPOST
                                         URL:postURL
                                  parameters:postDict];
            
            // Set the account
            [postToMyWall setAccount:_localInstance.facebookAccount];
            
            [postToMyWall performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                // Check for errors, output in alertview
                NSLog(@"Status Code: %li", (long)[urlResponse statusCode]);
                NSLog(@"Response Data: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                
                if (error)
                {
                    NSLog(@"Error message: %@", [error localizedDescription]);
                    [self showAlertViewWithString:[error localizedDescription]];
                }
                
                if ([urlResponse statusCode] == 200) {
                    NSString *successMessage = @"The post has been made successfully.";
                    [self showAlertViewWithString:successMessage];
                }
                
                if ([urlResponse statusCode] == 400) {
                    NSLog(@"The OAuth token has expired. Renewing Access Token.");
                    [_localInstance renewFacebookCredentials];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHud];
                });
            }];
            
            postToMyWall;
        });
        
        // Memory Management
        postToMyWall = nil;
        
    }
}

-(void)showAlertViewWithString:(NSString *)string
{
    //main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Result" message:[NSString stringWithFormat:@"%@", string] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    });
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
