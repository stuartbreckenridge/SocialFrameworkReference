//
//  TWBSocialHelper.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 13/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import "TWBSocialHelper.h"


@interface TWBSocialHelper ()

@property (nonatomic) ACAccountStore *facebookAccountStore;

/**
 For Facebook SLRequest methods, each app needs a Facebook App ID. This can be setup at https://developers.facebook.com.
 The name of the app shows up on Facebook posts as "via <app name>". Replace xxxxxxxx below with your App ID.
 */
#define kFacebookAppIdentifier @"xxxxxxxxxxxxx"

@end

@implementation TWBSocialHelper

+(instancetype)sharedHelper
{
    static dispatch_once_t pred;
    static TWBSocialHelper *instance = nil;
    
    dispatch_once(&pred, ^{instance = [[self alloc] initSingleton];});
    return instance;
}

-(instancetype)initSingleton
{
    self = [super init];
    
    if (self)
    {
        // Init code goes here, if necessary.
    }
    
    return self;
}

#pragma mark - Twitter Methods
-(void)requestAccessToTwitterAccounts
{
    // Create an account store
    ACAccountStore *twitter = [[ACAccountStore alloc] init];
    
    // Create an account type
    ACAccountType *twitterAccountType = [twitter accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    // Request Access to the twitter account
    [twitter requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         // If access is granted:
         if (granted)
         {
             // Specify the twitter account to use
             _twitterAccount = [[ACAccount alloc] initWithAccountType:twitterAccountType];
             _twitterAccounts = [twitter accountsWithAccountType:twitterAccountType];
             
             if ([_twitterAccounts count] == 0) {
                 NSLog(@"There are no Twitter accounts.");
             } else{
                 _twitterAccount = [_twitterAccounts firstObject];
                 /*
                  If you wish to see the username of the account being used uncomment out the next line of code
                  */
                 //NSLog(@"Username: %@", _twitterAccount.username);
                 _twitterAccessGranted = YES;
             }
         }
         
         // If permission is not granted to use the Twitter account:
         else
         {
             _twitterAccessGranted = NO;
         }
     }];
}

-(void)changeTwitterAccountToAccountAtIndex:(long)i
{
    _twitterAccount = [_twitterAccounts objectAtIndex:i];
}

// Facebook Methods
-(void)requestReadAccessToFacebook
{
    // Specify the permissions required
    NSArray *permissions = @[@"read_stream", @"email"];
    
    // Specify the audience
    NSDictionary *facebookOptions = [NSDictionary new];
    facebookOptions = @{ACFacebookAppIdKey : kFacebookAppIdentifier,
                        ACFacebookAudienceKey :  ACFacebookAudienceFriends,
                        ACFacebookPermissionsKey : permissions};
    
    // Create an Account Store
    _facebookAccountStore = [[ACAccountStore alloc] init];
    
    
    // Specify the Account Type
    ACAccountType *accountType = [_facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    if (!accountType.accessGranted) {
        _readAccessGranted = NO;
        _writeAccessGranted = NO;
    }
    
    // Perform the permission request
    [_facebookAccountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            _readAccessGranted = YES;
            NSLog(@"Read permissions granted.");
            NSArray *array = [_facebookAccountStore accountsWithAccountType:accountType];
            _facebookAccount = [array lastObject];
            [self requestWriteAccessToFacebook];
        }
        if (error) {
            if (error.code == 6) {
                NSLog(@"Error: There is no Facebook account setup.");
            } else
            {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }
    }];
}

-(void)requestWriteAccessToFacebook
{
    // Publish permissions will only be requested if read access has been granted, otherwise an alert will be generated.
    if (_readAccessGranted)
    {
        // Specify the permissions required
        NSArray *permissions = @[@"publish_stream"];
        
        // Specify the audience
        NSDictionary *facebookOptions = [NSDictionary new];
        facebookOptions = @{ACFacebookAppIdKey : kFacebookAppIdentifier,
                            ACFacebookAudienceKey :  ACFacebookAudienceFriends,
                            ACFacebookPermissionsKey : permissions};
        
        // Specify the Account Type
        ACAccountType *accountType = [_facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        if (!accountType.accessGranted) {
            _readAccessGranted = NO;
            _writeAccessGranted = NO;
        }
        
        // Perform the permission request
        [_facebookAccountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                _writeAccessGranted = YES;
                NSArray *array = [_facebookAccountStore accountsWithAccountType:accountType];
                _facebookAccount = [array lastObject];
                
                NSLog(@"Write permissions granted.");
            }
            
            if (error) {
                if (error.code == 6) {
                    NSLog(@"Error: There is no Facebook account setup.");
                } else
                {
                    NSLog(@"Error: %@", [error localizedDescription]);
                }
            }
        }];
    }
    
    else
    {
        UIAlertView *readPermission = [[UIAlertView alloc] initWithTitle:@"Permissions Required" message:@"Read permissions are required before requesting publish permissions." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [readPermission show];
        readPermission = nil;
    }

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"ReadAccessGranted"
     object:nil];
}



-(void)renewFacebookCredentials
{
    [_facebookAccountStore renewCredentialsForAccount:_facebookAccount
                                           completion:^(ACAccountCredentialRenewResult renewResult, NSError *error) {
                                               if (error) {
                                                   NSLog(@"Error Renewing Credentials:%@", [error localizedDescription]);
                                               } else{
                                                   [self requestReadAccessToFacebook];
                                               }
                                               
                                               NSLog(@"ACAccountCredentialRenewResult: %ld", (long)renewResult);
                                           }];
}


@end
