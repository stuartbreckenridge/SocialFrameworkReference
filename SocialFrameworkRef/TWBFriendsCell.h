//
//  TWBFriendsCell.h
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 14/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWBFriendsCell : UITableViewCell


@property (nonatomic,weak) IBOutlet UIImageView *profileImage;
@property (nonatomic,weak) IBOutlet UILabel *fullName;
@property (nonatomic,weak) IBOutlet UILabel *userName;

@end
