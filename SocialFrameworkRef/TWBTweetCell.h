//
//  TWBTweetCell.h
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 15/10/2013.
//  Copyright (c) 2013 TheWorkingBear. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWBTweetCell : UITableViewCell

/**
 A UITextView used for the tweet string.
 */
@property (nonatomic, weak) IBOutlet UITextView *theTweet;

/**
 A UILabel used for the author's full name.
 */
@property (nonatomic, weak) IBOutlet UILabel *theAuthorFullName;

/**
 A UILabel used for the author's @screen_name.
 */
@property (nonatomic, weak) IBOutlet UILabel *theAuthorUserName;

/**
 A UIImageView used for the author's profile picture.
 */
@property (nonatomic, weak) IBOutlet UIImageView *theAuthorProfileImage;




@end
