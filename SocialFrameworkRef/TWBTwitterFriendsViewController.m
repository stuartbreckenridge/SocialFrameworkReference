//
//  TWBTwitterFriendsViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 14/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import "TWBTwitterFriendsViewController.h"
#import "TWBFriendsCell.h"
#import "TWBSocialHelper.h"
#import "MBProgressHUD.h"


@interface TWBTwitterFriendsViewController ()

@property BOOL downloadComplete;
@property int downloadCount;
@property (nonatomic) NSMutableArray  *downloadedImages;
@property (nonatomic) TWBSocialHelper *localInstance;
@property (nonatomic) MBProgressHUD   *theHud;

@end

@implementation TWBTwitterFriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    _downloadComplete = NO;
    [self downloadData];
}


#pragma mark - Custom Download Methods
/**
 The downloadData method performs two requests. The first - getFriendsRequest - downloads 10 friends. The second, getFriendsDetailsRequest, downloads extra details based on the user_id's returned from the first request. Finally, it fires a separate request to download profile images for the downloaded friends.
 @warning This is a very syncronous method of displaying the user's friend list and not very user friendly.
 @see downloadProfileImages
 */
-(void)downloadData
{
    _localInstance               = [TWBSocialHelper sharedHelper];
    [self showHud];

    NSURL *twitterFriendsURL     = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];

    NSDictionary *requestParams  = @{@"count": @"10"};// The count key specifies the maximum amount of friends you wish to download in one request.

    // Create a request
    SLRequest *getFriendsRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                      requestMethod:SLRequestMethodGET
                                                                URL:twitterFriendsURL
                                                         parameters:requestParams];

    [getFriendsRequest setAccount:_localInstance.twitterAccount];
    
    
    [getFriendsRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (error) {
            NSLog(@"There was an error:%@", [error localizedDescription]);
            NSLog(@"Potential Resolution: %@", [error localizedRecoverySuggestion]);
        } else
            
        {
            // If there is no error, the response data is output in the log.
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
            //NSLog(@"%@", jsonResponse);
            
            // Create a comma separated list of ID's
            NSArray *idArray = [jsonResponse objectForKey:@"ids"];
            NSString *idList = [idArray componentsJoinedByString:@","];
            
            //NSLog(@"idList = %@", idList);
            
            NSURL *detailedFriendsURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"];
            
            NSDictionary *friendsParams = @{@"user_id": idList};
            
            SLRequest *getFriendsDetailsRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                     requestMethod:SLRequestMethodGET
                                                                               URL:detailedFriendsURL
                                                                        parameters:friendsParams];
            
            [getFriendsDetailsRequest setAccount:_localInstance.twitterAccount];
            
            [getFriendsDetailsRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                //NSLog(@"HTTP Response Code: %i", [urlResponse statusCode]);
                
                if (error) {
                    NSLog(@"There was an error:%@", [error localizedDescription]);
                    NSLog(@"Potential Resolution: %@", [error localizedRecoverySuggestion]);
                }
                
                else
                {
                    NSArray *jsonResponse2 = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
                    
                    NSMutableArray *realNames = [[NSMutableArray alloc] init];
                    NSMutableArray *screenNames = [[NSMutableArray alloc] init];
                    NSMutableArray *imageURLs    = [[NSMutableArray alloc] init];
                    
                    for (NSDictionary *dict in jsonResponse2)
                    {
                        NSString *realName = [dict objectForKey:@"name"];
                        NSString *screenName = [NSString stringWithFormat:@"@%@", [dict objectForKey:@"screen_name"]];
                        NSString *profileImage = [dict objectForKey:@"profile_image_url_https"];
                        NSString *highResImage = [profileImage stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
                        [realNames addObject: realName];
                        [screenNames addObject:screenName];
                        [imageURLs addObject:highResImage];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _profileImages = [imageURLs mutableCopy];
                        _twitterUserNames = [screenNames mutableCopy];
                        _realLifeNames = [realNames mutableCopy];
                        [self downloadProfileImages];
                    });
                    
                    realNames = nil;
                    screenNames = nil;
                    imageURLs = nil;
                }
            }];
        }
    }];
}

/**
 This method downloads the profile images for each friend using the URLs in the _profileImages mutableArray.
 */
-(void)downloadProfileImages
{
    if (_downloadedImages == nil) {
        _downloadedImages = [[NSMutableArray alloc] init];
    }
    
    _downloadCount = 0;
    
    if (_downloadCount <= [_profileImages count])
    {
        // Retrieve the URL of the profile image
        NSURL *url = [NSURL URLWithString:[_profileImages objectAtIndex:_downloadCount]];
        
        NSOperationQueue *downloadQueue = [NSOperationQueue new];
        NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:downloadQueue];
        
        NSURLSessionDownloadTask *downloadTask = [downloadSession downloadTaskWithURL:url];
        [downloadTask resume];
    }
}



#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_realLifeNames count];
}

- (TWBFriendsCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TWBFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    cell.userName.text = [_twitterUserNames objectAtIndex:indexPath.row];
    cell.fullName.text = [_realLifeNames objectAtIndex:indexPath.row];
    
    if (_downloadComplete == YES)
    {
        UIImage *image = [_downloadedImages objectAtIndex:indexPath.row];
        cell.profileImage.image = image;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [session invalidateAndCancel];
    NSData *imageData = [NSData dataWithContentsOfURL:location];
    UIImage *imageFromData = [UIImage imageWithData:imageData];
    [_downloadedImages insertObject:imageFromData atIndex:_downloadCount];
    
    _downloadCount++;
    
    if (_downloadCount < [_profileImages count]) {
        
        // Retrieve the URL of the profile image
        NSString *urlString = [_profileImages objectAtIndex:_downloadCount];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSOperationQueue *downloadQueue = [NSOperationQueue new];
        NSURLSession *downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:downloadQueue];
        
        NSURLSessionDownloadTask *downloadTask = [downloadSession downloadTaskWithURL:url];
        [downloadTask resume];
        
    }
    
    if ([_downloadedImages count] == [_profileImages count])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _downloadComplete = YES;
            [self.tableView reloadData];
            [self hideHud];
        });
    }
    
    imageFromData = nil;
    imageData = nil;
    
}
- (IBAction)goBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

#pragma mark - ProgressHud
-(void)showHud
{
    if (_theHud == nil) {
        _theHud = [[MBProgressHUD alloc] init];
    }
    
    _theHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _theHud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    _theHud.labelText = @"Downloading Friends";
}

-(void)hideHud
{
    [_theHud hide:YES];
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



#pragma mark - Memory
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
