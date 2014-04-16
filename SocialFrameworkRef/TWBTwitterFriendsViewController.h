//
//  TWBTwitterFriendsViewController.h
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 14/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWBTwitterFriendsViewController : UITableViewController <UIActionSheetDelegate, NSURLSessionDownloadDelegate>


@property (nonatomic) NSMutableArray *profileImages;
@property (nonatomic) NSMutableArray *realLifeNames;
@property (nonatomic) NSMutableArray *twitterUserNames;

@end
