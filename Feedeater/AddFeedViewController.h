//
//  AddFeedViewController.h
//  Feedeater
//
//  Created by Edwin Boyko on 12/08/2016.
//  Copyright © 2016 Edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFeedViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *addManuallyButton;

@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
