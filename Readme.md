Readme
-----------------------------

##Introduction
The aim of this demo app is to have a repository of all the common Social Framework methods. The app uses both SLComposeViewController and SLRequest and supports Twitter, Facebook, Flickr, and Vimeo accounts.

###Thanks!
Included in this app is the NSString+HTML.h class by Michael Waterfall; and the GTMNSString+HTML.h from Google. Usage of these classes is subject to their respective license agreement.

Additionally, graphics used in this application are from Glyphish (www.glyphish.com). If you like them, buy them.

###General Design Notes
#####TWBSocialHelper.h
This is a singleton class used in this demo to manage various elements related to the user's social network accounts.

###Twitter
######Important
In the TWBTwitterViewController's viewDidLoad method, a request is made to the SBSocialHelper class for access to the user's Twitter accounts. You should allow access!

######Notes
> All SLComposeViewController methods check for an available Twitter account using the isAvailableForServiceType method. If no Twitter account(s) are available a UIAlertView is presented.

> All SLRequest methods use Twitter API v1.1.

>Specifically for SLRequest methods, you can select which Twitter account to use via the Account selector. The account highlighted in green is the currently active account.

![Account Selector](http://www.stuarticus.com/wp-content/uploads/2013/08/Accounts.png) 

![Accounts](http://www.stuarticus.com/wp-content/uploads/2013/08/Accounts2.png)

####Twitter Methods
#####Method 0 - Posting Text with SLComposeViewController
This method uses SLComposeViewController to present Apple's stock tweet sheet for posting to Twitter.

#####Method 1 - Posting Text and an Image with SLComposeViewController
This method uses SLComposeViewController to present Apple's stock tweet sheet for posting to Twitter. An image from the application bundle is also attached to the tweet. 

#####Method 2 - Posting Text with SLRequest
This method uses SLRequest to post a tweet with text to the user's timeline. This method will not do anything if access has not been granted. A success alert view is presented if the posting was successful.

#####Method 3 - Posting Text and an Image with SLRequest
This method uses SLRequest to post a tweet with text and an image to the user's timeline. This method will not do anything if access has not been granted. A success alert view is presented if the posting was successful.

#####Method 4 - Viewing Friends with SLRequest
This method returns the users id numbers, e.g. 12345, then requests more data about each user id returned - profile image, screen name, and real name, and then presents a table view with that data. Lots of NSDictionarys and NSArrays. 

#####Method 5 - View Timeline with SLRequest
This method downloads the current authenticated user's timeline (using the default number of tweets). The method parses through the json response and then creates a SBTweetDetails object (a tweet); then pushes a tableview onscreen which displays the tweet.

###Facebook
######Important
Facebook requires a separate read and write request to be made for each permission, in respect of methods using SLRequest. In SBFacebookViewController's method a request is made for the read permission. If a method required write permissions, a request is made, and the method needs to be rerun by the user.

######Notes
> For SLRequest methods a Facebook App Identifier is required. This needs to be setup at https://developers.facebook.com.

####Facebook Methods
#####Method 0 - Post Text with SLComposeViewController
This method uses SLComposeViewController to present Apple's stock Facebook post sheet for posting to Facebook.

#####Method 1 - Post Text and Image with SLComposeViewController
This method uses SLComposeViewController to present Apple's stock Facebook post sheet for posting to Facebook. An image from the application bundle is also attached to the post.

#####Method 2 - Update Wall with SLRequest
This method uses SLRequest to post an update to the users wall with a message, a link, an image, a caption, a name, and a description. This method needs to be run twice: the first time will request write permission, the second will update the user's wall.

Note, the components of a Facebook update:
![Facebook Message Components](http://www.stuarticus.com/wp-content/uploads/2013/08/FB_Message.png)

#####Method 3 - View Friends with SLRequest
TBC

#####Method 4 - View Wall with SLRequest
TBC


