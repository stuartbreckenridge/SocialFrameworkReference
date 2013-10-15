//
//  TWBTwitterTimelineViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 15/10/2013.
//  Copyright (c) 2013 TheWorkingBear. All rights reserved.
//

#import "TWBTwitterTimelineViewController.h"
#import "TWBTweetObject.h"
#import "TWBTweetCell.h"
#import "TWBSocialHelper.h"
#import "NSString+HTML.h"
#import "MBProgressHUD.h"
@import Social;

@interface TWBTwitterTimelineViewController ()

/**
 arrayOfTweets contains all downloaded tweets that are each stored in a TWBTweetObject
 */
@property (nonatomic) NSMutableArray *arrayOfTweets;

/**
 The downloadCount is used as a counter to ensure that all profile images are downloaded before reloading the tableView.
 */
@property int downloadCount;


@property (nonatomic) TWBSocialHelper *localInstance;
@property (nonatomic) MBProgressHUD *theHud;

@end

@implementation TWBTwitterTimelineViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _localInstance = [TWBSocialHelper sharedHelper];
    _downloadCount = 0;
    [self downloadTimeline];
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_arrayOfTweets count];
}

- (TWBTweetCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TWBTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.theTweet.text = nil;
    
    TWBTweetObject *theTweet = [_arrayOfTweets objectAtIndex:indexPath.row];
    
    cell.theTweet.text = theTweet.tweetString;
    cell.theAuthorFullName.text = theTweet.tweetRealName;
    cell.theAuthorUserName.text = [NSString stringWithFormat:@"@%@",theTweet.tweetUserName];
    
    if (theTweet.profileImage) {
        cell.theAuthorProfileImage.image = theTweet.profileImage;
    } else
    {
        cell.theAuthorProfileImage.image = [UIImage imageNamed:@"TwitterBar"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Custom Download Methods
/**
 This method downloads the latest 50 tweets from the user's timeline.
 
 It then creates an NSURLSessionDownloadTask to download the profile images of each tweet author in the timeline. Once all profile images are downloaded the tableView is reloaded and presented to the user.
 @warning This is a very syncronous method of displaing tweets and not very user friendly.
 @see downloadProfileImages
 */
-(void)downloadTimeline
{
    [self showHud];
    
    _arrayOfTweets = [[NSMutableArray alloc] init];
    
    NSURL *timelineURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    
    NSDictionary *params = @{@"count": @"50"};
    
    // Create a request
    SLRequest *getUserTimeline = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodGET
                                                              URL:timelineURL
                                                       parameters:params];
    
    // Set the account for the request
    [getUserTimeline setAccount:_localInstance.twitterAccount];
    
    
    // Perform the request
    [getUserTimeline performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (error)
        {
            NSLog(@"There was an error performing the request: %@", [error localizedDescription]);
        }
        
        else
        {
            NSArray *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
            
            //NSLog(@"Twitter Response: %@", jsonResponse);
            
            for (NSDictionary *dictionary in jsonResponse)
            {
                // Get the tweet text
                NSString *tweetText = [dictionary objectForKey:@"text"];
                // Decode the tweet
                NSString *decodedTweet = [tweetText stringByDecodingHTMLEntities];
                
                // Get the user details
                NSDictionary *user = [dictionary objectForKey:@"user"];
                NSString *name = [user objectForKey:@"name"];
                NSString *screenName = [user objectForKey:@"screen_name"];
                NSString *profileImage = [user objectForKey:@"profile_image_url"];
                NSString *highResImage = [profileImage stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
                
                TWBTweetObject *tweetObject = [[TWBTweetObject alloc] init];
                tweetObject.tweetString = decodedTweet;
                tweetObject.tweetUserName = screenName;
                tweetObject.tweetRealName = name;
                tweetObject.profileImageURL = [NSURL URLWithString:highResImage];
                [_arrayOfTweets addObject:tweetObject];
                
                tweetObject = nil;
                user = nil;
                name = nil;
                screenName = nil;
                profileImage = nil;
                highResImage = nil;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self downloadProfileImages];
            });
            
        }
    }];
    
    // Memory Management
    timelineURL = nil;
    params = nil;
    getUserTimeline = nil;
}


-(void)downloadProfileImages
{
    if (_downloadCount < [_arrayOfTweets count])
    {
        TWBTweetObject *t = [_arrayOfTweets objectAtIndex:_downloadCount];
        NSOperationQueue *downloadQueue = [NSOperationQueue new];
        NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:downloadQueue];
        
        NSURLSessionDownloadTask *downloadTask = [downloadSession downloadTaskWithURL:t.profileImageURL];
        
        [downloadTask resume];
        t = nil;
    }
    
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            [self.tableView reloadData];
            _downloadCount = 0;
        });
    }
}


#pragma mark - NSURLSessionDownloadDelegate
/* Sent when a download task that has completed a download.  The delegate should
 * copy or move the file at the given location to a new location as it will be
 * removed when the delegate message returns. URLSession:task:didCompleteWithError: will
 * still be called.
 */
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    // Download Task
    //NSLog(@"Download Task");
    NSData *imageData = [NSData dataWithContentsOfURL:location];
    UIImage *imageFromData = [UIImage imageWithData:imageData];
    
    TWBTweetObject *obj = [_arrayOfTweets objectAtIndex:_downloadCount];
    obj.profileImage = imageFromData;
    obj = nil;
    
    _downloadCount++;
    [self downloadProfileImages];
}

#pragma mark - NSURLSessionDelegate
/* Sent periodically to notify the delegate of download progress. */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //NSLog(@"Did Write Data");
}

/* Sent when a download has been resumed. If a download failed with an
 * error, the -userInfo dictionary of the error will contain an
 * NSURLSessionDownloadTaskResumeData key, whose value is the resume
 * data.
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

#pragma mark - ProgressHud
-(void)showHud
{
    if (_theHud == nil) {
        _theHud = [[MBProgressHUD alloc] init];
    }
    
    _theHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _theHud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    _theHud.labelText = @"Downloading Timeline";
}

-(void)hideHud
{
    [_theHud hide:YES];
}

@end
