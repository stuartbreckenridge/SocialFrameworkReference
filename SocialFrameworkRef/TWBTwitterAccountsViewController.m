//
//  TWBTwitterAccountsViewController.m
//  SocialFrameworkRef
//
//  Created by Stuart Breckenridge on 13/10/2013.
//  Copyright (c) 2013 Stuart Breckenridge. All rights reserved.
//

#import "TWBTwitterAccountsViewController.h"
#import "TWBSocialHelper.h"
#import "TWBTwitterAccountCell.h"
@import Accounts;

#define kTwitterLookUpURL @"https://api.twitter.com/1.1/users/lookup.json"

@interface TWBTwitterAccountsViewController ()

@property (nonatomic, strong) TWBSocialHelper *localInstance;

@end

@implementation TWBTwitterAccountsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _localInstance = [TWBSocialHelper sharedHelper];
}

- (IBAction)navigateBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 //
                             }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_localInstance twitterAccounts] count];
}

- (TWBTwitterAccountCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    TWBTwitterAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.screenName.text = nil;
    cell.fullName.text = nil;
    cell.currentlySelected.image = nil;
    
    ACAccount *theAccount = [_localInstance.twitterAccounts objectAtIndex:indexPath.row];
    
    cell.screenName.text = theAccount.accountDescription;
    cell.fullName.text = theAccount.username;
    
    if ([cell.screenName.text isEqualToString:_localInstance.twitterAccount.accountDescription]) {
        cell.currentlySelected.image = [UIImage imageNamed:@"Thumbs"];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_localInstance changeTwitterAccountToAccountAtIndex:indexPath.row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView reloadData];
}


@end
