//
//  StoryDetailsTableViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 02/09/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface StoryDetailsTableViewController : UITableViewController

@property (strong, nonatomic) NSObject *selectedStory;

@property (strong, nonatomic) NSManagedObject *currentFeed;

@end
