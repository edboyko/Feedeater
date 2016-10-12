//
//  FeedListViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 13/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LatestNewsViewController.h"
#import "FeedCell.h"
#import "EditFeedViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DataManager.h"

@interface FeedListViewController : UITableViewController
- (IBAction)showOptions:(UIBarButtonItem *)sender;
@property (strong, nonatomic) LatestNewsViewController *newsVC;

@property (strong, nonatomic) DataManager *dataManager;
- (void)edit:(UIButton *)sender;
- (IBAction)addAlert:(id)sender;

@end
