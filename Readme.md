Readme
-----------------------------
[![Build Status](https://travis-ci.org/theworkingbear/SocialFrameworkReference.png?branch=master)](https://travis-ci.org/theworkingbear/SocialFrameworkReference)

##Introduction
The aim of this demo app is to have a repository of all the common Social Framework methods. The app uses both `SLComposeViewController`, `SLRequest` and `UIActivityViewController` and supports Twitter, Facebook, and Flickr.

###Acknowledgements
Included in this app is the NSString+HTML.h class by Michael Waterfall; the GTMNSString+HTML.h class from Google; and the MBProgressHud.h class created by Matej Bukovinski . Usage of these classes is subject to their respective license agreement.

Additionally, graphics used in this application are from Glyphish (www.glyphish.com). If you like them, buy them.

###General Design Notes
#####TWBSocialHelper.h
This is a singleton class used in this demo to manage various elements related to the user's social network accounts.

###Twitter
######Important
In the `TWBTwitterViewController`'s viewDidLoad method, a request is made to the `TWBSocialHelper` class for access to the user's Twitter accounts. You should allow access!

######Notes
> All `SLComposeViewController` methods check for an available Twitter account using the isAvailableForServiceType method. If no Twitter account(s) are available a UIAlertView is presented.

> All `SLRequest` methods use Twitter API v1.1.

>Specifically for `SLRequest` methods, you can select which Twitter account to use via the Account selector. The account highlighted with the **Thumbs Up** is the currently active account.

![Account Selector](http://f.cl.ly/items/2X421I0b412g3H1u0g29/AccountSelector.png) 

![Methods](http://f.cl.ly/items/360X25463X3n1a2d3X2m/TwitterMethods.png)

####Twitter Methods
#####Posting Text with SLComposeViewController
This method uses `SLComposeViewController` to present Apple's stock tweet sheet for posting to Twitter.

#####Posting Text and an Image with SLComposeViewController
This method uses `SLComposeViewController` to present Apple's stock tweet sheet for posting to Twitter. An image from the application bundle is also attached to the tweet. 

#####Posting Text with SLRequest
This method uses `SLRequest` to post a tweet with text to the user's timeline. This method will not do anything if access has not been granted. A success alert view is presented if the posting was successful.

#####Posting Text and an Image with SLRequest
This method uses `SLRequest` to post a tweet with text and an image to the user's timeline. This method will not do anything if access has not been granted. A success alert view is presented if the posting was successful.

#####Viewing Friends with SLRequest
This method returns the users id numbers, e.g. 12345, then requests more data about each user id returned - profile image, screen name, and real name, and then presents a table view with that data. Lots of NSDictionarys and NSArrays. 

#####View Timeline with SLRequest
This method downloads the current authenticated user's timeline (using the default number of tweets). The method parses through the json response and then creates a SBTweetDetails object (a tweet); then pushes a tableview onscreen which displays the tweet.

###Facebook
######Important
Facebook requires a separate read and write request to be made for each permission, in respect of methods using `SLRequest`. In `TWBFacebookViewController`'s `viewDidLoad` method a request is made for the read permission. Upon success of that method, a write request is made.

######Notes
> For SLRequest methods a Facebook App Identifier is required. This needs to be setup at https://developers.facebook.com. Additionally, the bundle ID of the app must match the bundle ID on the Facebook website.

####Facebook Methods
#####Post Text with SLComposeViewController
This method uses `SLComposeViewController` to present Apple's stock Facebook post sheet for posting to Facebook.

#####Post Text and Image with SLComposeViewController
This method uses `SLComposeViewController` to present Apple's stock Facebook post sheet for posting to Facebook. An image from the application bundle is also attached to the post.

#####Update Wall with SLRequest
This method uses `SLRequest` to post an update to the users wall with a message, a link, an image, a caption, a name, and a description. This method needs to be run twice: the first time will request write permission, the second will update the user's wall.

Note, the components of a Facebook update:
![Facebook Message Components](http://f.cl.ly/items/0h0W1g011B2g0m2K1j0p/FB_Message.png)

###Flickr
There are no `SLComposeViewController` methods available for Flickr. The alternative is to use `UIActivityViewController`.
#####Post an Image with UIActivityViewController
This method uses `SLComposeViewController` to present Apple's stock Facebook post sheet for posting to Facebook.

---
### Changes
1.0.2 (004)
- Changed `+(TWBSharedHelper *)sharedHelper` to `+(instancetype)sharedHelper`
- Updates to Readme. 
- Various NSLogs removed.

1.0.3b1 (005)
- Methods in `TWBTwitterViewController` are now using GCC Code Block Evaluation.
- Resolved memory leak in `TWBTwitterTimelineViewController` by invalidating the `downloadSession` when all image downloads are complete.
