//
//  TWBTwitterAccountCell.h
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 13/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TWBTwitterAccountCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *currentlySelected;
@property (nonatomic, weak) IBOutlet UILabel     *fullName;
@property (nonatomic, weak) IBOutlet UILabel     *screenName;


@end
