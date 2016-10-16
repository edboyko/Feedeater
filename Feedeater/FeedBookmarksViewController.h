//
//  FeedBookmarksViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 19/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface FeedBookmarksViewController : UITableViewController

@property (strong, nonatomic) NSManagedObject *currentFeed;

@end
