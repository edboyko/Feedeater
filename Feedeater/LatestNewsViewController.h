//
//  LatestNewsViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 13/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsTableViewController.h"
#import "FeedBookmarksViewController.h"
#import "StoryCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface LatestNewsViewController : UITableViewController <UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSManagedObject *selectedFeed;
@property (strong, nonatomic) NSString *feedURL;

@property (weak, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSMutableArray *newsArray;

@property (strong, nonatomic) UISearchController *searchController;

@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSMutableArray *visibleNews;

@property (strong, nonatomic) DataManager *dataManager;


- (IBAction)toHomeScreen:(id)sender;

@end
