//
//  EditFeedViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 15/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DataManager.h"

@interface EditFeedViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UITextField *urlField;
@property (strong, nonatomic) NSString *feedName;
@property (strong, nonatomic) NSString *feedURL;
@property (strong, nonatomic) NSManagedObject *selectedFeed;
@property (strong, nonatomic) DataManager *dataManager;
- (IBAction)confirmChanges:(UIButton *)sender;
- (IBAction)deleteFeed:(UIButton *)sender;

@end
