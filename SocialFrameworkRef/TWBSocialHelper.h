//
//  TWBSocialHelper.h
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 13/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//


#import <Foundation/Foundation.h>
@import Social;
@import Accounts;

@interface TWBSocialHelper : NSObject

/**
 This method creates a shared instance of the SocialHelper.
 */
+(instancetype)sharedHelper;

// Public Methods related to Twitter //
/**
 This method follows the stock process for requesting access to the user's Twitter accounts. In order to let other classes know that access has been granted, a public Boolean, _twitterAccessGranted, is set to YES once the authentication flow is complete. Other classes can use the _twitterAccount ivar for their SLRequest methods. The default Twitter account is the first object in the _twitterAccounts array.
 */
-(void)requestAccessToTwitterAccounts;

/**
 This will change the currently active Twitter account for SLRequest methods.
 @param i An integer that relates to the index of the selected account in the account array within the settings app.
 */
-(void)changeTwitterAccountToAccountAtIndex:(long)i;


// Public Properties related to Twitter //
/**
 The selected twitter account of the user. The default is the first account in the array of accounts; however, this can be changed either in code or by the user using the changeTwitterAccountToAccountAtIndex:(int)i method.
 */
@property (readonly, nonatomic) ACAccount *twitterAccount;


/**
 An array of the user's Twitter accounts setup in the settings app.
 */
@property (readonly, nonatomic) NSArray *twitterAccounts;

/**
 Boolean letting other classes know if Twitter access has been granted.
 */
@property (readonly, nonatomic, assign) __block BOOL twitterAccessGranted;


// Public Methods Related to Facebook
/**
 This method will request the @"read_stream" permission for Facebook. If permission is given, the _readAccessGranted boolean is set to YES. The read and write requests MUST be separate.
 @see http://developers.facebook.com
 */
-(void)requestReadAccessToFacebook;

/**
 This method will request the @"publish_stream" permission for Facebook. This permission is required in order to publish to the user's stream. If permission is given, the _writeAccessGranted boolean is set to YES.
 @pre This method will not function if the user has not given the @"read_stream" permission.
 */
-(void)requestWriteAccessToFacebook;

/**
 This method will renew the credentials associated with the Facebook account.
 */
-(void)renewFacebookCredentials;

// Public Properties related to Facebook
/**
 The Facebook account of the user. Unlike Twitter, there is only one Facebook account.
 */
 @property (readonly, nonatomic) ACAccount *facebookAccount;

/**
 Boolean specifying if the user has given the appilcation permission to read from the user's Facebook account.
 */
@property (readonly, nonatomic, assign) __block BOOL readAccessGranted;

/**
 Boolean specifying if the user has given the appilcation permission to write to the user's Facebook wall.
 */
@property (readonly, nonatomic, assign) __block BOOL writeAccessGranted;






@end
