//
//  LatestNewsViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 13/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryDetailsTableViewController.h"

@interface LatestNewsViewController : UITableViewController

@property (strong, nonatomic) NSManagedObject *selectedFeed;

- (IBAction)toHomeScreen:(id)sender;

@end
