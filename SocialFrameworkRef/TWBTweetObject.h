//
//  TWBTweetObject.h
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 14/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//
/**
 @class TWBTweetObject 
 @details The TWBTweetObject is a basic representation of a tweet's attributes.
 */

#import <Foundation/Foundation.h>

@interface TWBTweetObject : NSObject

/**
 An NSString representing the text of the tweet.
  */
@property (nonatomic) NSString *tweetString;

/**
 An NSString representing the user name of the tweet author.
 */
@property (nonatomic) NSString *tweetUserName;

/**
 An NSString representing the real name of the tweet author.
 */
@property (nonatomic) NSString *tweetRealName;

/**
 An NSURL of the tweet author's profile image.
 */
@property (nonatomic) NSURL *profileImageURL;

/**
 The UIImage that is downloaded from the profileImageURL
 */
@property (nonatomic) UIImage *profileImage;


@end
