//
//  AddFeedViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AXPopoverView/AXPopoverView.h>
#import <AXAttributedLabel.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DataManager.h"

@interface AddFeedViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) DataManager *dataManager;
@property (strong, nonatomic) IBOutlet UIButton *addManuallyButton;

- (IBAction)findFeeds:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *resultsArray;

@property (strong, nonatomic) MBProgressHUD *hud;

-(BOOL)validateUrl:(NSString*)candidate;

@end
